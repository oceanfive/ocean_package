
module OceanPackage
  class Command

    # 命令参数
    attr_accessor :arguments
    # .xcworkspace 文件路径
    attr_accessor :workspace_path
    # scheme 名称
    attr_accessor :scheme
    # 配置信息: Debug, Release
    attr_accessor :configuration

    # archive 归档路径
    attr_accessor :archive_path
    # 导出ipa包使用的plist文件
    attr_accessor :export_options_plist

    # attr_accessor :ding_enabled
    # attr_accessor :ding_token

    # 公司名称
    attr_accessor :company_name
    # 本次打包的时间
    attr_accessor :date_time

    # fir平台token
    attr_accessor :fir_token
    # 本次更新内容
    attr_accessor :change_log

    def initialize(params = [])
      argv = CLAide::ARGV.new(params)

      @arguments = argv.arguments
      puts "arguments: #{@arguments}"

      @workspace_path = argv.option("workspace-path", "")
      puts "workspace_path: #{@workspace_path}"

      @scheme = argv.option("scheme", "")
      puts "scheme: #{@scheme}"

      @configuration = argv.option("configuration", OceanPackage::Constants::DEFAULT_CONFIGURATION)
      puts "configuration: #{@configuration}"

      @archive_path = argv.option("archive-path", OceanPackage::Constants::DEFAULT_ARCHIVE_PATH)
      puts "archive_path: #{@archive_path}"

      @company_name = argv.option("company-name", OceanPackage::Constants::DEFAULT_COMPANY_NAME)
      puts "company_name: #{@company_name}"

      @export_options_plist = argv.option("export-options-plist", "")
      puts "export_options_plist: #{@export_options_plist}"

      # @ding_enabled = argv.flag?("ding-enabled", false)
      # puts "ding_enabled: #{@ding_enabled}"
      #
      # @ding_token = argv.option("ding-token", "")
      # puts "ding_token: #{@ding_token}"

      # 使用空格会被xcodebuild错误分割，导致执行失败
      @date_time = Time.new.strftime("%Y-%m-%d_%H-%M-%S")
      puts "@date_time: #{@date_time}"

      @fir_token = argv.option("fir-token", "")
      puts "fir_token: #{@fir_token}"

      @change_log = argv.option("change-log", "")
      puts "change_log: #{@change_log}"

    end

    def validate!
      if !@arguments.include?("oceanpackage")
        puts "不包含命令 oceanpackage"
        return false
      end

      if @workspace_path.empty?
        puts "@workspace_path 内容为空"
        return false
      end

      if @scheme.empty?
        puts "@scheme 内容为空"
        return false
      end

      if @configuration.empty?
        puts "@configuration 内容为空"
        return false
      end

      return true
    end

    def final_workspace_path
      @workspace_path
    end

    def project_root_path
      File.dirname(final_workspace_path)
    end

    def project_name
      File.basename(final_workspace_path, ".*")
    end

    def custom_archive_path
      if @archive_path.end_with?('/')
        @archive_path
      else
        @archive_path + '/'
      end
    end

    def final_archive_path
      path = custom_archive_path
      path += @company_name + '/'
      path += project_name + '/'
      path += @date_time + '/'

      puts "final_archive_path: #{path}"

      return path
    end

    def archive_file_path
      path = final_archive_path
      path += project_name
      path += '.xcarchive'

      puts "archive_file_path: #{path}"
      return path
    end

    def ipa_file_path
      path = final_archive_path
      path += project_name
      path += '.ipa'

      puts "ipa_file_path: #{path}"
      return path
    end

    def final_change_log
      if @change_log.empty?
        commit_msg = syscall('git log --pretty=format:%s -1')
        return commit_msg
      else
        return @change_log
      end
    end

    def clean_cmd
      cmd = 'xcodebuild'
      cmd += ' clean'
      cmd += ' -workspace ' + @workspace_path
      cmd += ' -scheme ' + @scheme
      cmd += ' -configuration ' + @configuration

      puts "clean command: #{cmd}"

      return cmd
    end

    def archive_cmd
      cmd = 'xcodebuild'
      cmd += ' -workspace ' + final_workspace_path
      cmd += ' -scheme ' + @scheme
      cmd += ' -configuration ' + @configuration
      cmd += ' -archivePath ' + archive_file_path
      cmd += ' archive'

      puts "archive command: #{cmd}"

      return cmd
    end

    def export_cmd_parms
      cmd = ''
      cmd += ' -exportArchive'
      cmd += ' -archivePath ' + archive_file_path
      cmd += ' -exportPath ' + final_archive_path
      cmd += ' -exportOptionsPlist ' + @export_options_plist
      return cmd
    end

    def export_cmd
      cmd = 'xcodebuild'
      cmd += export_cmd_parms
      puts "export command: #{cmd}"
      return cmd
    end

    def run
      prepare
      cd_root_path
      clean
      archive
      export
      upload
    end

    def prepare
      validate!
      FileUtils.mkdir_p(final_archive_path)
      if @export_options_plist.empty?
        puts "@@export_options_plist 内容为空"
      end
    end

    def cd_root_path
      puts "cd_root_path ===="
      FileUtils.cd(project_root_path)
      puts FileUtils.pwd
    end

    def clean
      puts "clean ====="
      res = system(clean_cmd)
      puts "#{res}"
      puts "$? ====="
      puts $?
      puts "$0 ====="
      puts $0
    end

    def archive
      puts "archive ====="
      res = system(archive_cmd)
      puts "#{res}"
      puts "$? ====="
      puts $?
      puts "$0 ====="
      puts $0
    end

    def export
      puts "export ====="
      # run_export_sh
      
      res = system(export_cmd)
      puts "#{res}"
      puts "$? ====="
      puts $?
      puts "$0 ====="
      puts $0
    end

    def upload
      if @fir_token.empty? == false
        path = final_archive_path + 'fir.log'
        fir = OceanPackage::Fir.new(@fir_token, final_change_log, ipa_file_path, path)
        fir.run

        # ipa_file_path = '/Users/ocean/Documents/myipas/zto2/ztoExpressClient/2020-07-26_01-15-23/ztoExpressClient.ipa'
        # path = '/Users/ocean/Documents/myipas/zto2/ztoExpressClient/2020-07-26_01-15-23/fir.log'
        # fir = OceanPackage::Fir.new(@fir_token, final_change_log, ipa_file_path, path)
        # fir.run
      end

    end

    def find_export_shell_path
      return '/Users/ocean/Desktop/code/ruby/ocean_package/lib/ocean_package/export.sh'
      # puts 'find_export_shell_path ===='
      # path = FileUtils.pwd + '/export.sh'
      # puts path
      # return path
    end

    def run_export_sh
      path = find_export_shell_path
      cmd = 'sh ' + path
      cmd += ' ' + export_cmd_parms

      puts 'run_export_sh ===='
      puts cmd

      res = system(cmd)
      puts "#{res}"
      puts "$? ====="
      puts $?
      puts "$0 ====="
      puts $0

    end

  end

end
