require "test_helper"

class OceanPackageTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::OceanPackage::VERSION
  end

  def test_it_does_something_useful

    puts "#{OceanPackage::Constants::DEFAULT_ARCHIVE_PATH}"

    # path = '/Users/ocean/Documents/myipas/ztoExpressClient.ipa'
    # ipa = OceanPackage::Ipa.new(path)
    # ipa.make_tmp_dir
    # ipa.cp_to_tmp_dir
    # # ipa.tmp_ipa_file_path
    # ipa.rename_tmp_ipa_file
    # ipa.unzip_ipa_file
    # ipa.find_info_plist_path
    # # ipa.copy_info_plist_file
    # ipa.info_plist_value
    # ipa.log_value


    # path = '/Users/ocean/Documents/myipas/zto2/ztoExpressClient/2020-08-02_14-05-20/ztoExpressClient.ipa'
    #
    # ipa = OceanPackage::Ipa.new(path)
    # ipa.run

    # content = "当前平台: iOS\n\n"
    # content += "APP名称: " + "中通快递" + "\n\n"
    # content += "当前版本: " + "5.9.0" + "(1)" + "\n\n"
    # content += "打包耗时: " + "todo" + "\n\n"
    # content += "发布环境: " + "Debug" + "\n\n"
    # content += "更新描述: " + "Bug fixed" + "\n\n"
    # content += "发布时间: " + "time" + "\n\n"
    # content += "下载链接: [点我](http://wuhaiyang.top/f6z1?release_id=5f265b5ab2eb461d4a46d92f)" + "\n\n"
    # content += "![二维码](https://wuhyimages.oss-cn-shanghai.aliyuncs.com/qrcode/5f265b5ab2eb461d4a46d92f)"
    #
    # puts "web hook message: \n#{content}"
    #
    #
    # ding = OceanPackage::DingTalk.new('1d93cc41c8bf5c55ab5a58f1c5119dbca274c9725539b70c9a3025d3e456571d')
    # # ding.send_text_message(content, ['15221047750'], false )
    #
    # content_value = "# 中通快递 \n\n" + content
    #
    # ding.send_card_message("iOS 来新包啦~", content_value)
    #
    # ding.send_text_message("iOS 来新包啦~", ["15221047750"])
    #
    #
    # time = Time.new


  end


end
