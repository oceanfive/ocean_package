
module OceanPackage
  class Fir

    # token
    attr_accessor :token
    # 更新日志
    attr_accessor :change_log
    # ipa文件包路径
    attr_accessor :ipa_file_path
    # log文件路径
    attr_accessor :log_path

    def initialize(token, change_log = "", ipa_file_path, log_path)
      @token = token
      @change_log = change_log
      @ipa_file_path = ipa_file_path
      @log_path = log_path
    end

    # 命令：查看 fir 信息
    def info_cmd
      'fir -v'
    end

    # 命令：fir 登录
    def login_cmd
      cmd = 'fir login'
      cmd += ' -T ' + @token

      Log.info("fir login command: #{cmd}")

      cmd
    end

    # 命令：上传ipa文件到fir平台
    def publish_cmd
      cmd = 'fir publish'
      cmd += ' ' + @ipa_file_path
      cmd += ' -c ' + @change_log
      cmd += ' -Q'
      cmd += ' | tee ' + @log_path

      Log.info("fir publish command: #{cmd}")

      cmd
    end

    # 运行
    def run
      unless check
        return
      end
      login
      publish
    end

    # 校验
    def check

      token_value = "#{@token}"
      if token_value.empty?
        Log.error("fir token is empty, please check !!!")
        return false
      end

      ipa_file_path_value = "#{@ipa_file_path}"
      if ipa_file_path_value.empty?
        Log.error("ipa file path is empty, please check !!!")
        return false
      end

      return true
    end

    # 登录
    def login
      system(info_cmd)
      res = system(login_cmd)

      Log.info("fir login result: #{res}")

      unless res == true
        Log.error("fir login fail, please check !!!")
        exit(1)
      end

    end

    # 上传
    def publish
      res = system(publish_cmd)

      Log.info("fir publish result: #{res}")

      unless res == true
        Log.error("fir publish fail, please check !!!")
        exit(1)
      end
    end

    # 查找 release_id
    def find_release_id
      # 正则表达式匹配
      pattern = /.*Release id is.*/
      release_id = ''
      File.open(@log_path, "r") do |f|
        f.each_line do |line|
          line_s = "#{line}"
          if line_s =~ pattern
            release_id = line_s.split(' ').last
            break
          end
        end
      end
      Log.info("fir release id value: #{release_id}")
      release_id
    end

    # 查找下载链接
    def find_link
      # 正则表达式匹配
      pattern = /.*Published succeed:.*/
      link = ''
      File.open(@log_path, "r") do |f|
        f.each_line do |line|
          line_s = "#{line}"
          if line_s =~ pattern
            link = line_s.split(' ').last
            break
          end
        end
      end
      Log.info("fir link value: #{link}")
      link
    end

    # 构建完整的下载链接，有 release id
    def whole_download_link
      link = find_link
      link += '?release_id='
      link += find_release_id

      Log.info("fir whole link value: #{link}")

      link
    end

    # 查找下载二维码的文件路径
    def find_qr_code_path
      # 正则表达式匹配
      pattern = /.*Local qrcode file:.*/
      path = ''
      File.open(@log_path, "r") do |f|
        f.each_line do |line|
          line_s = "#{line}"
          if line_s =~ pattern
            path = line_s.split(' ').last
            break
          end
        end
      end
      Log.info("fir qr code path value: #{path}")
      path
    end
  end
end