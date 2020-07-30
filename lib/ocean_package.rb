require 'fileutils'

# 注意：这里使用 require_relative 来引用文件
require_relative 'ocean_package/version'
require_relative 'ocean_package/config'
require_relative 'ocean_package/command'
require_relative 'ocean_package/constants'
require_relative 'ocean_package/fir'
require_relative 'ocean_package/oss'

module OceanPackage
  require 'claide'

  def self.run(argvs)
    puts "====="
    puts ARGV
    puts "====="

    command = OceanPackage::Command.new(argvs)
    command.run


    # # command = OceanPackage::Command.new(config)
    #
    # argv = CLAide::ARGV.new(ARGV)
    # if !argv.arguments.include?("oceanpackage")
    #   puts "不包含命令 oceanpackage"
    #   exit 1
    # end
    #
    # puts "包含命令 oceanpackage"
  end

end
