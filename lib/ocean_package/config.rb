
module OceanPackage

  class Config

    attr_accessor :workspace_path
    attr_accessor :scheme
    attr_accessor :configuration

    # attr_accessor :ding_enabled
    # attr_accessor :ding_token

    def initialize(params = [])
      argv = CLAide::ARGV.new(params)

      @workspace_path = argv.option("workspace-path", "")
      puts "workspace_path: #{@workspace_path}"

      @scheme = argv.option("scheme", "")
      puts "scheme: #{@scheme}"

      @configuration = argv.option("configuration", "")
      puts "configuration: #{@configuration}"

      # @ding_enabled = argv.flag?("ding-enabled", false)
      # puts "ding_enabled: #{@ding_enabled}"
      #
      # @ding_token = argv.option("ding-token", "")
      # puts "ding_token: #{@ding_token}"



    end

    def valid

    end

  end

end
