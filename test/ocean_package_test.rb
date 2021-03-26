require "test_helper"

class OceanPackageTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::OceanPackage::VERSION
  end

  def test_it_does_something_useful

    # puts "#{OceanPackage::Constants::DEFAULT_ARCHIVE_PATH}"
    #
    # path = "/Users/ocean/Documents/Ipas/zto/ztoExpressClient/2020-08-06_13-10-23"
    # open_cmd = "open #{path}"
    # system(open_cmd)

    # pgy = OceanPackage::Pgy.new("99214400b3fd0d06ba7f0597ed84d70c", "格式一下", "/Users/ocean/Documents/myipas/ztoExpressClient.ipa")
    # pgy.run

    # path = "/Users/ocean/Desktop/code/iOS/study/StudyCocoapods/Pods/Pods.xcodeproj"
    #
    # uuid_prefix = Digest('SHA256').hexdigest(File.basename(path)).upcase
    # puts uuid_prefix
    # # 46EB2E34D7EBEAC2CAD91944D62742189F4E7E7668A808B2C6AB86E9714371FE
    #
    # puts Pathname.new(path).expand_path

    # 087E14CFD01C52C8F320802FBE1C96AD
    # path = "/Users/ocean/Desktop/code/iOS/study/StudyCocoapods/Pods/AFNetworking/AFNetworking/AFHTTPSessionManager.m"
    # md5 = Digest::MD5.hexdigest(path).upcase
    # puts md5

    # path = "/Users/ocean/Desktop/code/iOS/study/StudyCocoapods/StudyCocoapods/UILabel+HYCateogry.m"
    # md5 = Digest::MD5.hexdigest(path).upcase
    # puts md5
    # UILabel+HYCateogry.h 12DB50D9BF5A60CE7F809D5FB75643E9
    # UILabel+HYCateogry.m 9CD03FD5C3D1381C059A66CC45F98929


    # 目标文件夹，默认是当前目录
    # dir = "/Users/ocean/Desktop/code/iOS/study/StudyCocoapods/Pods/BMKLocationKit"
    #
    # # puts '\r\n you not set target dir, so use current dir(pwd) !!!\r\n' unless @target_dir
    # puts 'final dir: ' + dir.to_s
    #
    # puts "\n hhhh"
    # puts 'bbbb'



  end
end
