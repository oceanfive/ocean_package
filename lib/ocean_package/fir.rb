
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

    def initialize(token, change_log, ipa_file_path, log_path)
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

      puts "fir login command: #{cmd}"

      return cmd
    end

    # 命令：上传ipa文件到fir平台
    def publish_cmd
      cmd = 'fir publish'
      cmd += ' ' + @ipa_file_path
      cmd += ' -c ' + @change_log
      cmd += ' -Q'
      cmd += ' | tee ' + @log_path

      puts "fir publish command: #{cmd}"

      return cmd
    end

    def run
      login
      publish
    end

    def login
      system(info_cmd)
      res = system(login_cmd)
      puts "#{res}"
      puts "$? ====="
      puts $?
      puts "$0 ====="
      puts $0
    end

    def publish
      res = system(publish_cmd)
      puts "#{res}"
      puts "$? ====="
      puts $?
      puts "$0 ====="
      puts $0
    end

    # 查找 release_id
    def find_release_id
      puts "find_release_id ===="
      # 正则表达式匹配
      pattern = /.*Release id is.*/
      release_id = ''
      File.open(@log_path, "r") do |f|
        f.each_line do |line|
          line_s = "#{line}"
          if line_s =~ pattern
            release_id = line_s.split(' ').last
            puts "find release id: #{release_id}"
            break
          end
        end
      end
      puts "release_id_value: #{release_id}"
      release_id
    end

    # 查找下载链接
    def find_link
      puts "find_link ===="
      # 正则表达式匹配
      pattern = /.*Published succeed:.*/
      link = ''
      File.open(@log_path, "r") do |f|
        f.each_line do |line|
          line_s = "#{line}"
          if line_s =~ pattern
            link = line_s.split(' ').last
            puts "find link: #{link}"
            break
          end
        end
      end
      puts "link_value: #{link}"
      link
    end

    # 构建完整的下载链接，有
    def whole_download_link
      link = find_link
      link += '?release_id='
      link += find_release_id

      puts "完整下载链接: #{link}"

      link
    end

    # 查找下载二维码的文件路径
    def find_qr_code_path
      puts "find_qr_code_path ===="
      # 正则表达式匹配
      pattern = /.*Local qrcode file:.*/
      path = ''
      File.open(@log_path, "r") do |f|
        f.each_line do |line|
          line_s = "#{line}"
          if line_s =~ pattern
            path = line_s.split(' ').last
            puts "find qr code path: #{path}"
            break
          end
        end
      end
      puts "qr code path value: #{path}"
      path
    end

  end
end