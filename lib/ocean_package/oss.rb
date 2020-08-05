
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

    # 最终的 bucket path
    def final_oss_bucket_path
      if @oss_bucket_path.end_with?('/')
        @oss_bucket_path
      else
        @oss_bucket_path + '/'
      end
    end

    # 文件在 oss 上的路径
    def oss_file_path(name)
      final_oss_bucket_path + name
    end

    # 校验
    def check
      oss_bucket_name_value = "#{@oss_bucket_name}"
      oss_bucket_path_value = "#{@oss_bucket_path}"
      oss_endpoint_value = "#{@oss_endpoint}"

      if oss_bucket_name_value.empty? || oss_bucket_path_value.empty? || oss_endpoint_value.empty?
        return false
      end
      return true
    end

    # 上传文件到 oss 的命令
    def upload_cmd(file_path, name)
      cmd = '${HOME}/ossutilmac64' + ' cp ' + file_path
      cmd += ' '
      cmd += 'oss://' + @oss_bucket_name + oss_file_path(name)

      Log.divider
      Log.info("oss upload_cmd: #{cmd}")
      Log.divider

      cmd
    end

    # 上传文件到 oss
    # file_path：文件路径
    # name：文件在 oss 上的名称
    # return: 文件的链接 url
    def upload(file_path, name)

      file_path_value = "#{file_path}"
      name_value = "#{name}"
      if file_path_value.empty? || name_value.empty?

        Log.error("oss upload file path or name is empty, please check !!!")

        return ''
      end

      cmd = upload_cmd(file_path, name)
      res = system(cmd)
      Log.info("oss upload result: #{res}")

      unless res == true
        Log.error("oss upload fail, please check !!!")
        return ''
      end

      url = fetch_file_url(name)

      Log.info("oss file url: #{url}")

      url
    end

    # 文件 name 在 oss 上的路径
    def fetch_file_url(name)
      'https://' + @oss_bucket_name + '.' + @oss_endpoint + oss_file_path(name)
    end
  end

end