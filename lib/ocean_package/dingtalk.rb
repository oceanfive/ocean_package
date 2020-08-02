
module OceanPackage

  class DingTalk
    require "dingbot"

    attr_accessor :token

    def initialize(token)
      @token = token
      configure_ding_bot
    end

    def configure_ding_bot
      DingBot.configure do |config|
        config.endpoint = 'https://oapi.dingtalk.com/robot/send' # API endpoint URL, default: ENV['DINGTALK_API_ENDPOINT'] or https://oapi.dingtalk.com/robot/send
        config.access_token = @token # access token, default: ENV['DINGTALK_ACCESS_TOKEN']
      end
    end

    # 发送 text 消息，有 @ 某人效果
    def send_text_message(content = '', at_mobiles = [], is_at_all = false)
      message = DingBot::Message::Text.new(content, at_mobiles, is_at_all)
      DingBot.send_msg(message)
    end

    # 发送消息卡片，可以附带链接，图片
    def send_card_message(title = '', text = '')
      message = DingBot::Message::WholeActionCard.new(title, text)
      DingBot.send_msg(message)
    end

  end
end