require 'fileutils'
require 'dingbot'
require 'cfpropertylist'
require 'semantic_logger'
require 'multipart_post'
require 'net/http/post/multipart'
require 'json'

# 注意：这里使用 require_relative 来引用文件
require_relative 'ocean_package/version'
require_relative 'ocean_package/config'
require_relative 'ocean_package/command'
require_relative 'ocean_package/constants'
require_relative 'ocean_package/fir'
require_relative 'ocean_package/oss'
require_relative 'ocean_package/dingtalk'
require_relative 'ocean_package/ipa'
require_relative 'ocean_package/logger'
require_relative 'ocean_package/package'
require_relative 'ocean_package/pgy'

module OceanPackage
  require 'claide'

  def self.run(argvs)
    puts "====="
    puts ARGV
    puts "====="

    command = OceanPackage::Command.new(argvs)
    command.run

  end

end
