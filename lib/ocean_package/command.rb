
module OceanPackage
  class Command

    # xcodebuild 打包相关
    attr_accessor :package
    # fir 平台
    attr_accessor :fir
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

    def initialize(params = [])
      argv = CLAide::ARGV.new(params)

      @arguments = argv.arguments
      Log.info("arguments: #{@arguments}")

      workspace_path = argv.option("workspace-path", "")
      Log.info("workspace_path: #{workspace_path}")

      scheme = argv.option("scheme", "")
      Log.info("scheme: #{scheme}")

      configuration = argv.option("configuration", OceanPackage::Constants::DEFAULT_CONFIGURATION)
      Log.info("configuration: #{configuration}")

      archive_path = argv.option("archive-path", OceanPackage::Constants::DEFAULT_ARCHIVE_PATH)
      Log.info("archive_path: #{archive_path}")

      company_name = argv.option("company-name", OceanPackage::Constants::DEFAULT_COMPANY_NAME)
      Log.info("company_name: #{company_name}")

      export_options_plist = argv.option("export-options-plist", "")
      Log.info("export_options_plist: #{export_options_plist}")

      @package = OceanPackage::Package.new(workspace_path, scheme, configuration, archive_path, company_name, export_options_plist)

      fir_token = argv.option("fir-token", "")
      Log.info("fir_token: #{fir_token}")

      change_log = argv.option("change-log", "")
      @change_log = change_log
      Log.info("change_log: #{change_log}")

      fir_log_path = @package.final_archive_path + 'fir.log'
      @fir = OceanPackage::Fir.new(fir_token, final_change_log, @package.ipa_file_path, fir_log_path)

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

    def run
      package.run
      upload
      send_ding_talk_msg
    end

    # 上传 ipa 文件
    def upload
      upload_to_fir
    end

    # 上传到 fir 平台
    def upload_to_fir
      fir.run
      upload_qr_code(fir.find_qr_code_path, fir.find_release_id)
      @ipa_download_link = fir.whole_download_link
    end

    # 上传 二维码 QRCode 图片到 oss
    def upload_qr_code(path, name)
      @qr_code_url = oss.upload(path, name)
    end

    # 总共时间，单位 秒 s
    def compute_total_time
      time1 = package.start_time
      time2 = Time.now
      seconds = time2 - time1

      Log.info("total time: #{seconds}")

      seconds
    end

    # web hook 消息标题
    def make_web_hook_message_title
      "iOS 来新包啦~"
    end

    # web hook 消息内容
    def make_web_hook_message
      ipa = OceanPackage::Ipa.new(package.ipa_file_path)
      ipa.run

      # markdown 格式
      content = "# #{ipa.display_name} \n\n"
      content += "当前平台: iOS \n\n"
      content += "APP名称: " + ipa.display_name + "\n\n"
      content += "当前版本: " + ipa.version + "(#{ipa.build_version})" + "\n\n"
      content += "打包耗时: " + "#{compute_total_time}" + "s" + "\n\n"
      content += "发布环境: " + "#{package.configuration}" + "\n\n"
      content += "更新描述: " + final_change_log + "\n\n"
      content += "发布时间: " + Time.new.strftime("%Y年%m月%d日 %H时%M分%S秒") + "\n\n"
      content += "下载链接: [点我](#{@ipa_download_link})" + "\n\n"
      content += "![二维码](#{@qr_code_url})"

      Log.info("web hook message: \n#{content}")

      content
    end

    def send_ding_talk_msg
      # 消息卡片，富文本
      title = make_web_hook_message_title
      content = make_web_hook_message

      ding.send_card_message(title, content)
      ding.send_text_message(title, @at_mobiles)
    end

  end

end
