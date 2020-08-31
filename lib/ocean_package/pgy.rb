
module OceanPackage
  class Pgy
    require 'multipart_post'
    require 'net/http/post/multipart'
    require 'json'

    # # 用户Key，用来标识当前用户的身份
    # attr_accessor :user_key
    # API Key，用来识别API调用者的身份，如不特别说明，每个接口中都需要含有此参数。
    attr_accessor :api_key
    # # 表示一个App组的唯一Key。
    # attr_accessor :app_key
    # 更新日志
    attr_accessor :change_log
    # ipa文件包路径
    attr_accessor :ipa_file_path

    # 短链接
    attr_accessor :short_url
    # 二维码链接
    attr_accessor :qr_code_url

    # 初始化
    def initialize(api_key, change_log, ipa_file_path)
      @api_key = api_key
      @change_log = change_log
      @ipa_file_path = ipa_file_path
      @short_url = ""
      @qr_code_url = ""
    end

    # 校验
    def check

      # user_key_value = "#{@user_key}"
      # if user_key_value.empty?
      #   Log.error("pgy user key is empty, please check !!!")
      #   return false
      # end

      api_key_value = "#{@api_key}"
      if api_key_value.empty?
        Log.error("pgy api key is empty, please check !!!")
        return false
      end

      # app_key_value = "#{@app_key}"
      # if app_key_value.empty?
      #   Log.error("pgy app key is empty, please check !!!")
      #   return false
      # end

      ipa_file_path_value = "#{@ipa_file_path}"
      if ipa_file_path_value.empty?
        Log.error("ipa file path is empty, please check !!!")
        return false
      end

      return true
    end

    # 运行
    def run
      unless check
        return
      end
      publish
    end

    # 上传
    def publish
      url = URI.parse('https://www.pgyer.com/apiv2/app/upload')
      File.open("#{@ipa_file_path}") do |ipa|

        # 构建必要的参数
        ipa_file_name = Time.new.strftime("%Y-%m-%d_%H-%M-%S") + ".ipa"
        require_params = {
            "file" => UploadIO.new(ipa, "multipart/form-data", ipa_file_name),
            "_api_key" => "#{@api_key}",
            "buildUpdateDescription" => "#{@change_log}",
        }

        # 构造请求
        req = Net::HTTP::Post::Multipart.new(url.path, require_params)

        # 网络http
        net = Net::HTTP.new(url.host, url.port)
        # 这里需要设置，否则会有 EPIPE: Broken pipe 错误
        net.use_ssl = true
        net.verify_mode = OpenSSL::SSL::VERIFY_NONE
        net.set_debug_output($stdout)

        # 发起请求
        res = net.start do |http|
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          http.request(req)
        end

        Log.divider
        Log.info(res)

        # 具体参考 https://www.pgyer.com/doc/view/api#paramInfo
        case res
        when Net::HTTPSuccess
          # 响应是字符串类型，需要转为json进行处理
          json_value = JSON.parse(res.body)
          Log.divider
          Log.info(json_value)
          # 成功
          data = json_value["data"]
          short_url = data["buildShortcutUrl"]
          qr_code_url = data["buildQRCodeURL"]
          @short_url = short_url
          @qr_code_url = qr_code_url
          Log.error(@short_url)
          Log.error(@qr_code_url)
        else
          # 失败
          Log.error("pgy publish fail, please check !!!")
          exit(1)
        end
      end
    end

    # 获取下载链接
    def get_download_url
      # 需要有固定的前缀
      url = "https://www.pgyer.com/" + @short_url

      Log.divider
      Log.info(url)

      url
    end

    # 获取二维码链接
    def get_qr_code_url
      url = "#{@qr_code_url}"

      Log.divider
      Log.info(url)

      url
    end
  end
end