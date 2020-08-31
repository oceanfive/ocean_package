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

    pgy = OceanPackage::Pgy.new("99214400b3fd0d06ba7f0597ed84d70c", "格式一下", "/Users/ocean/Documents/myipas/ztoExpressClient.ipa")
    pgy.run

  end

end
