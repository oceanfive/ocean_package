
module OceanPackage

  class Package
    include OceanPackage::TimeFlow::Mixin

    # .xcworkspace 文件路径
    attr_accessor :workspace_path
    # scheme 名称
    attr_accessor :scheme
    # 配置信息: Debug, Release
    attr_accessor :configuration
    # 额外的打底参数，比如对buildsettings进行重写
    attr_accessor :extra_export_params

    # archive 归档路径
    attr_accessor :archive_path
    # 导出ipa包使用的plist文件
    attr_accessor :export_options_plist

    # 公司名称
    attr_accessor :company_name
    # 本次打包的时间
    attr_accessor :date_time

    # 开始时间
    attr_accessor :start_time
    # 结束时间
    attr_accessor :end_time

    # ipa 最大保存的数目
    attr_accessor :ipa_max_retain_number
    # 打包完成是否打开文件夹
    attr_accessor :open_finder

    def initialize(workspace_path, scheme, configuration, archive_path, company_name, export_options_plist, extra_export_params, open_finder)
      @workspace_path = workspace_path
      @scheme = scheme
      @configuration = configuration
      @archive_path = archive_path
      @company_name = company_name
      @date_time = Time.new.strftime("%Y-%m-%d_%H-%M-%S")
      @export_options_plist = export_options_plist
      @extra_export_params = extra_export_params

      @ipa_max_retain_number = 3
      @open_finder = open_finder
      # 预设置开始时间
      @start_time = Time.now
    end

    # workspace 的路径
    def final_workspace_path
      "#{@workspace_path}"
    end

    # 项目的根目录，也就是 .xcworkspace 所在的目录
    def project_root_path
      File.dirname(final_workspace_path)
    end

    # 项目的名称
    def project_name
      File.basename(final_workspace_path, ".*")
    end

    # 执行打包相关命令
    def run
      @start_time = Time.now
      # 检查必须参数
      check
      # 清理历史的ipa
      clean_history_ipa
      # clean 项目
      clean
      # 打包项目
      archive
      # 导出 ipa 包
      export
      @end_time = Time.now
      # 返回打包成功的 ipa 文件路径
      ipa_file_path
      if @open_finder
        open_ipa_file_path
      end
    end

    # 一些校验
    def check

      workspace_path_value = final_workspace_path
      unless workspace_path_value.end_with?(".xcworkspace")
        Log.error("workspace path error, please check !!!")
        exit(1)
      end

      scheme_value = "#{@scheme}"
      if scheme_value.empty?
        Log.error("please check scheme value !!!")
        exit(1)
      end

      configuration_value = "#{@configuration}"
      if configuration_value.empty?
        Log.error("please check configuration value !!!")
        exit(1)
      end
      # 有可能项目存在自定义的 configuration，所以不进行校验

      archive_path_value = "#{@archive_path}"
      if archive_path_value.empty?
        Log.error("please check archive path !!!")
        exit(1)
      end

      export_options_plist_value = "#{@export_options_plist}"
      if export_options_plist_value.empty?
        Log.error("please check export options plist value !!!")
        exit(1)
      end

    end

    # **************************************
    # clean history
    # **************************************

    def clean_history_ipa
      path = final_archive_path_company_pro

      sub_paths = Array.new
      Dir.each_child(path) do |x|
        unless "#{x}".eql?(".DS_Store")
          sub_paths.push("#{x}")
        end
      end

      if sub_paths.length > @ipa_max_retain_number
        Log.divider
        Log.info("clean history ipas: begin =======")

        count = sub_paths.length - @ipa_max_retain_number
        deleted_paths = sub_paths.first(count)

        deleted_paths.each do |p|
          new_path = path + p
          Log.info(new_path)
          delete_directory(new_path)
        end

        Log.info("clean history ipas: end =======")
        Log.divider
      end
    end

    def delete_directory(dirPath)
      if File.directory?(dirPath)
        Dir.foreach(dirPath) do |subFile|
          if subFile != '.' and subFile != '..'
            delete_directory(File.join(dirPath, subFile));
          end
        end
        Dir.rmdir(dirPath)
      else
        File.delete(dirPath)
      end
    end

    # **************************************
    # clean
    # **************************************

    # clean cmd
    def clean_cmd
      cmd = 'xcodebuild'
      cmd += ' clean'
      cmd += ' -workspace ' + @workspace_path
      cmd += ' -scheme ' + @scheme
      cmd += ' -configuration ' + @configuration

      Log.divider
      Log.info("clean command: #{cmd}")
      Log.divider

      cmd
    end

    # clean
    def clean
      time_flow.point_clean_time

      res = system(clean_cmd)
      Log.info("clean result: #{res}")

      unless res == true
        Log.error("clean fail, please check !!!")
        exit(1)
      end
    end

    # **************************************
    # archive
    # **************************************

    # archive 路径，会判断结尾 '/'
    def processed_archive_path
      if @archive_path.end_with?('/')
        @archive_path
      else
        @archive_path + '/'
      end
    end

    # 最终的打包路径，包含了公司，项目名称
    def final_archive_path_company_pro
      path = processed_archive_path
      unless "#{@company_name}".empty?
        path += @company_name + '/'
      end
      unless "#{project_name}".empty?
        path += project_name + '/'
      end

      path
    end

    # 最终的打包路径
    def final_archive_path
      path = final_archive_path_company_pro
      path += @date_time + '/'

      Log.info("final archive path: #{path}")

      # 不存在，需要进行创建，外部传入了 ipa 文件的情况
      FileUtils.mkdir_p(path)

      path
    end

    # xcarchive 文件路径
    def archive_file_path
      path = final_archive_path
      path += project_name
      path += '.xcarchive'

      Log.info("archive file path: #{path}")

      path
    end

    # archive cmd
    def archive_cmd
      cmd = 'xcodebuild'
      cmd += ' -workspace ' + final_workspace_path
      cmd += ' -scheme ' + @scheme
      cmd += ' -configuration ' + @configuration
      cmd += ' -archivePath ' + archive_file_path
      cmd += ' archive'
      cmd += ' -allowProvisioningUpdates'

      Log.divider
      Log.info("archive command: #{cmd}")
      Log.divider

      cmd
    end

    # archive
    def archive
      time_flow.point_archive_time

      res = system(archive_cmd)

      Log.info("archive result: #{res}")

      unless res == true
        Log.error("archive fail, please check !!!")
        exit(1)
      end

    end

    # **************************************
    # export
    # **************************************

    def export_cmd
      cmd = 'xcodebuild'
      cmd += ' -exportArchive'
      cmd += ' -archivePath ' + archive_file_path
      cmd += ' -exportPath ' + final_archive_path
      cmd += ' -exportOptionsPlist ' + @export_options_plist

      unless "#{@extra_export_params}".empty?
        # 分割
        params = "#{@extra_export_params}".split(",")
        # 再拼接
        joined_string = params.join(" ")

        unless joined_string.empty?
          cmd += ' ' + joined_string
        end
      end

      Log.divider
      Log.info("export command: #{cmd}")
      Log.divider

      cmd
    end

    def export
      time_flow.point_export_time

      res = system(export_cmd)

      Log.info("export result: #{res}")

      unless res == true
        Log.error("export fail, please check !!!")
        exit(1)
      end
    end

    # **************************************
    # ipa
    # **************************************

    # ipa 文件的路径
    def ipa_file_path
      path = final_archive_path
      path += project_name
      path += '.ipa'

      Log.info("ipa file path: #{path}")

      path

      # 也可以在该目录下查找 ipa 后缀的文件
    end

    # 打开所在目录
    def open_ipa_file_path
      path = final_archive_path
      open_cmd = "open #{path}"
      system(open_cmd)
    end

  end

end
