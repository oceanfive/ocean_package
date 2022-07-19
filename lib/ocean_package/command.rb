
module OceanPackage
  class Command
    include OceanPackage::TimeFlow::Mixin
    require 'net/http'

    # xcodebuild 打包相关
    attr_accessor :package
    # fir 平台
    attr_accessor :fir
    # 蒲公英平台
    attr_accessor :pgy
    # oss 对象
    attr_accessor :oss
    # ding ding
    attr_accessor :ding

    # 命令参数
    attr_accessor :arguments

    # 本次更新内容
    attr_accessor :change_log

    # @ 的手机号
    attr_accessor :at_mobiles

    # 自定义的ipa文件路径
    attr_accessor :custom_ipa_file_path

    # 整个流程时间记录上报url
    attr_accessor :time_flow_url

    # 整个流程时间记录上报url，额外的参数
    attr_accessor :time_flow_extra_req

    def initialize(params = [])
      argv = CLAide::ARGV.new(params)

      @arguments = argv.arguments
      Log.info("arguments: #{@arguments}")

      workspace_path = argv.option("workspace-path", "")
      Log.info("workspace_path: #{workspace_path}")

      scheme = argv.option("scheme", "")
      Log.info("scheme: #{scheme}")

      # 默认配置改为空，防止包环境错误
      configuration = argv.option("configuration", "")
      Log.info("configuration: #{configuration}")

      archive_path = argv.option("archive-path", OceanPackage::Constants::DEFAULT_ARCHIVE_PATH)
      Log.info("archive_path: #{archive_path}")

      company_name = argv.option("company-name", OceanPackage::Constants::DEFAULT_COMPANY_NAME)
      Log.info("company_name: #{company_name}")

      export_options_plist = argv.option("export-options-plist", "")
      Log.info("export_options_plist: #{export_options_plist}")

      ##### 自定义的 ipa 文件 #####
      ipa_file_path = argv.option("ipa-file-path", "")
      Log.info("ipa_file_path: #{ipa_file_path}")
      @custom_ipa_file_path = ipa_file_path

      extra_export_params = argv.option("extra-export-params", "")
      Log.info("extra-export-params: #{extra_export_params}")

      open_finder = argv.flag?("open-finder", false )
      Log.info("open-finder: #{open_finder}")

      time_flow_url = argv.option("time-flow-url", "")
      Log.info("time_flow_url: #{time_flow_url}")
      @time_flow_url = time_flow_url

      time_flow_extra_req = argv.option("time-flow-extra-req", "")
      Log.info("time_flow_extra_req: #{time_flow_extra_req}")
      @time_flow_extra_req = time_flow_extra_req

      # 自定义ipa文件，使用该文件作为 archive path
      tmp_archive_path = has_custom_ipa_file ? File.dirname("#{ipa_file_path}") : archive_path
      Log.info("tmp_archive_path: #{tmp_archive_path}")
      @package = OceanPackage::Package.new(workspace_path, scheme, configuration, tmp_archive_path, company_name, export_options_plist, extra_export_params, open_finder)

      fir_token = argv.option("fir-token", "")
      Log.info("fir_token: #{fir_token}")

      change_log = argv.option("change-log", "")
      @change_log = change_log
      Log.info("change_log: #{change_log}")

      fir_log_path = @package.final_archive_path + 'fir.log'
      @fir = OceanPackage::Fir.new(fir_token, final_change_log, final_ipa_file_path, fir_log_path)

      ##### 蒲公英 #####
      pgy_api_key = argv.option("pgy-api-key", "")
      @pgy = OceanPackage::Pgy.new(pgy_api_key, final_change_log, final_ipa_file_path)
      Log.info("pgy_api_key: #{pgy_api_key}")

      ##### oss #####
      oss_bucket_name = argv.option("oss-bucket-name", "")
      Log.info("oss_bucket_name: #{oss_bucket_name}")

      oss_bucket_path = argv.option("oss-bucket-path", "")
      Log.info("oss_bucket_path: #{oss_bucket_path}")

      oss_endpoint = argv.option("oss-endpoint", "")
      Log.info("oss_endpoint: #{oss_endpoint}")

      @oss = OceanPackage::Oss.new(oss_bucket_name, oss_bucket_path, oss_endpoint)

      ding_token = argv.option("ding-token", "")
      Log.info("ding_token: #{ding_token}")

      at_mobiles = argv.option("at-mobiles", "").split(",")
      Log.info("ding_at_mobiles: #{at_mobiles}")
      @at_mobiles = at_mobiles

      @ding = OceanPackage::DingTalk.new(ding_token)
    end

    # 最终的 change log
    def final_change_log
      if @change_log.empty?
        syscall('git log --pretty=format:%s -1')
      else
        @change_log
      end
    end

    # 是否设置了自定义的ipa文件
    def has_custom_ipa_file
      "#{@custom_ipa_file_path}".empty? ? false : true
    end

    # 最终的ipa文件路径
    def final_ipa_file_path
      has_custom_ipa_file ? "#{@custom_ipa_file_path}" : @package.ipa_file_path
    end

    # 运行
    def run
      time_flow.point_start_time
      # 没有自定义ipa文件，需要执行打包命令
      unless has_custom_ipa_file
        package.run
      end
      upload
      send_ding_talk_msg
      finished
    end

    # 上传 ipa 文件
    def upload
      time_flow.point_upload_ipa_time

      can_fir = fir.check
      can_pgy = pgy.check
      if can_fir
        Log.info("publish platform: fir")
        upload_to_fir
      elsif can_pgy
        Log.info("publish platform: pgy")
        upload_to_pgy
      else
        Log.info("publish platform: none, exit")
        exit(1)
      end
    end

    # ------ fir 平台 -------

    # 上传到 fir 平台
    def upload_to_fir
      fir.run
      upload_qr_code(fir.find_qr_code_path, fir.find_release_id)
      @ipa_download_link = fir.whole_download_link
    end

    # 上传 二维码 QRCode 图片到 oss
    # 后续其他平台，比如蒲公英也是需要类似的逻辑
    def upload_qr_code(path, name)
      @qr_code_url = oss.upload(path, name)
    end

    # ------ pgy 平台 -------
    def upload_to_pgy
      pgy.run
      @qr_code_url = pgy.get_qr_code_url
      @ipa_download_link = pgy.get_download_url
    end

    # 总共时间，单位 秒 s
    def compute_total_time
      time1 = package.start_time
      time2 = Time.now
      seconds = time2 - time1

      Log.info("total time: #{seconds}")

      seconds
    end

    # 总共时间，单位 分
    def compute_total_time_minute
      time1 = package.start_time
      time2 = Time.now
      minutes = (time2 - time1) / 60

      Log.info("total time: #{minutes} minute")

      minutes
    end

    # web hook 消息标题
    def make_web_hook_message_title
      "iOS 来新包啦~"
    end

    # web hook 消息内容
    def make_web_hook_message
      ipa = OceanPackage::Ipa.new(final_ipa_file_path)
      ipa.run

      # markdown 格式
      content = "# #{ipa.display_name} \n\n"
      content += "当前平台: iOS \n\n"
      content += "APP名称: " + ipa.display_name + "\n\n"
      content += "当前版本: " + ipa.version + "(#{ipa.build_version})" + "\n\n"
      content += "打包耗时: " + "#{compute_total_time_minute}" + " 分钟" + "\n\n"
      content += "发布环境: " + "#{package.configuration}" + "\n\n"
      content += "更新描述: " + final_change_log + "\n\n"
      content += "发布时间: " + Time.new.strftime("%Y年%m月%d日 %H时%M分%S秒") + "\n\n"
      content += "下载链接: [点我](#{@ipa_download_link})" + "\n\n"
      content += "![二维码](#{@qr_code_url})"

      Log.divider
      Log.info("web hook message: \n#{content}")
      Log.divider

      content
    end

    # 发送打包信息到钉钉
    def send_ding_talk_msg
      time_flow.point_notify_group_time

      # 消息卡片，富文本
      title = make_web_hook_message_title
      content = make_web_hook_message

      ding.send_card_message(title, content)
      ding.send_text_message(title, @at_mobiles)
    end

    # 打包完成
    def finished
      time_flow.point_end_time
      write_time_flow_data

      Log.divider
      Log.info("package finished")
      Log.divider
    end

    def write_time_flow_data
      time_flow_dir = @package.final_archive_path
      time_flow_file_path = "#{time_flow_dir}timeflow.json"
      params = time_flow.make_all_points
      json = JSON.dump(params)

      unless File.exist?(time_flow_file_path)
        FileUtils.touch(time_flow_file_path)
      end
      a_file = File.new(time_flow_file_path, "r+")
      if a_file
        a_file.syswrite(json)
        Log.info("write time flow to path(success): #{time_flow_file_path}")
      else
        Log.error("write time flow to path(fail): #{time_flow_file_path}")
      end

      upload_time_flow_data(params)
    end

    def upload_time_flow_data(data)
      time_flow_url_value = "#{@time_flow_url}"
      unless time_flow_url_value.empty?
        Log.info("upload time flow data")

        uri = URI.parse(time_flow_url_value)
        params = data

        # 分割
        extra_params = "#{@time_flow_extra_req}".split(",")
        # 再拼接
        extra_params.each do |p|
          extra_key_values = "#{p}".split("=")
          if extra_key_values.length == 2
            extra_key = "#{extra_key_values[0]}"
            extra_value = "#{extra_key_values[1]}"
            if extra_key.length > 0 && extra_value.length > 0
              params[extra_key] = extra_value
            end
          end
        end

        res = Net::HTTP.post_form(uri, params)
        Log.info("upload time flow data result: #{res.body}")
      end
    end

  end

end
