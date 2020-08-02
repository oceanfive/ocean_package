
module OceanPackage
  class Ipa

    # ipa 文件路径
    attr_accessor :path

    def initialize(path)
      @path = path
    end

    # ipa 文件所在的文件夹路径
    def ipa_dir_path
      dir_path = File.dirname(@path)

      Log.info("ipa dir path: #{dir_path}")

      dir_path
    end

    # ipa 文件名
    def ipa_name
      name = File.basename(@path, ".*")

      Log.info("ipa name: #{name}")

      name
    end

    # ipa文件名称，包含后缀
    def ipa_base_name
      name = File.basename(@path)

      Log.info(puts "ipa base name: #{name}")

      name
    end

    # 临时目录路径
    def ipa_tmp_dir_path
      tmp_path = ipa_dir_path
      tmp_path += '/' + ipa_name + '_tmp'
      tmp_path
    end

    # 临时目录下的ipa文件
    def tmp_ipa_file_path
      tmp_path = ipa_tmp_dir_path + '/' + ipa_base_name

      Log.info("tmp ipa file path: #{tmp_path}")

      tmp_path
    end

    # 临时目录下的 zip 文件路径，把 ipa 后缀改为 zip 后缀
    def tmp_ipa_zip_file_path
      zip_file = ipa_tmp_dir_path + '/' + ipa_name + '.zip'

      Log.info(puts "tmp ipa zip file path: #{zip_file}")

      zip_file
    end

    # 创建临时文件夹
    def make_tmp_dir
      FileUtils.mkdir_p(ipa_tmp_dir_path)
    end

    # 拷贝ipa文件到临时目录下
    def cp_to_tmp_dir
      FileUtils.cp(@path, ipa_tmp_dir_path)
    end

    # 冲命名ipa文件，ipa -> zip
    def rename_tmp_ipa_file
      ipa_file = tmp_ipa_file_path
      new_ipa_file = tmp_ipa_zip_file_path

      Log.info("rename ipa file #{ipa_file} to: #{new_ipa_file}")

      File.rename(ipa_file, new_ipa_file)
    end

    # 解压缩 zip 文件
    def unzip_ipa_file
      cmd = 'unzip -o'
      cmd += ' -d ' + ipa_tmp_dir_path
      cmd += ' ' + tmp_ipa_zip_file_path

      Log.info("unzip cmd: #{cmd}")

      res = system(cmd)
    end

    # 查找 info.plist 文件
    def find_info_plist_path
      plist_dir = ipa_tmp_dir_path
      plist_dir += '/Payload'

      cmd = 'find ' + plist_dir
      cmd += ' -maxdepth 2'
      cmd += ' -name Info.plist'

      Log.info("find info plist path cmd: #{cmd}")

      res = %x(#{cmd})
      # res = system(cmd)

      Log.info("info plist path: #{res}")

      res
    end

    def find_info_plist_dir
      plist_path = find_info_plist_path
      dir = File.dirname(plist_path)

      # Log.info("find info plist dir: #{dir}")

      dir
    end

    # 读取 info.plist 文件的值
    def info_plist_value
      @info ||= CFPropertyList.native_types(
          CFPropertyList::List.new(file: File.join(find_info_plist_dir, 'Info.plist')).value)

      # Log.info("info plist value: #{@info}")

      @info

      # 这种写法不行的，会有如下错误
      # UnexpectedError: IOError: File /Users/ocean/Documents/myipas/ztoExpressClient_tmp/Payload/ztoExpressClient.app/Info.plist  not readable!
      # @info ||= CFPropertyList.native_types(
      #     CFPropertyList::List.new(file: find_info_plist_path).value)
      #
      # puts "info_plist_value: #{@info}"
      # @info

    end

    # app 名称
    def display_name
      info_plist_value["CFBundleDisplayName"]
    end

    # bundle id
    def bundle_identifier
      info_plist_value["CFBundleIdentifier"]
    end

    # 版本
    def version
      info_plist_value["CFBundleShortVersionString"]
    end

    # build 版本
    def build_version
      info_plist_value["CFBundleVersion"]
    end

    def log_value
      display_name_value = display_name
      puts "CFBundleDisplayName: #{display_name_value}"

      bundle_identifier_value = bundle_identifier
      puts "CFBundleIdentifier: #{bundle_identifier_value}"

      version_value = version
      puts "CFBundleShortVersionString: #{version_value}"

      build_version_value = build_version
      puts "CFBundleVersion: #{build_version_value}"
    end

    # 执行相关操作
    def run
      make_tmp_dir
      cp_to_tmp_dir
      rename_tmp_ipa_file
      unzip_ipa_file
      info_plist_value
      log_value
    end

  end

end
