
module OceanPackage

  class Oss

    # oss bucket 名称
    attr_accessor :oss_bucket_name
    # oss bucket 路径
    attr_accessor :oss_bucket_path
    # oss endpoint
    attr_accessor :oss_endpoint

    def initialize(bucket_name, bucket_path, endpoint)
      @oss_bucket_name = bucket_name
      @oss_bucket_path = bucket_path
      @oss_endpoint = endpoint
    end

    def final_oss_bucket_path
      if @oss_bucket_path.end_with?('/')
        @oss_bucket_path
      else
        @oss_bucket_path + '/'
      end
    end

    def oss_file_path(name)
      final_oss_bucket_path + name
    end

    def upload_cmd(file_path, name)
      cmd = '${HOME}/ossutilmac64' + ' cp ' + file_path
      cmd += ' '
      cmd += 'oss://' + @oss_bucket_name + oss_file_path(name)

      puts "upload_cmd: #{cmd}"

      cmd
    end

    def upload(file_path, name)
      puts "oss upload ===== #{file_path} , #{name}"
      cmd = upload_cmd(file_path, name)
      res = system(cmd)
      puts "#{res}"
      puts "$? ====="
      puts $?
      puts "$0 ====="
      puts $0

      url = fetch_file_url(name)

      puts "fetch_file_url ==="
      puts url

    end

    def fetch_file_url(name)
      url = 'https://' + @oss_bucket_name + '.' + @oss_endpoint + oss_file_path(name)
      url
    end
  end

end