# OceanPackage

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/ocean_package`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ocean_package'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ocean_package
    
or

    $ sudo gem install ocean_package

其他需要安装的依赖

- `fir-cli`, [链接](https://github.com/FIRHQ/fir-cli)
- `ossutil`, [链接](https://help.aliyun.com/document_detail/120075.html?spm=a2c4g.11186623.2.45.6e491c7akyZ5HE)


```
sudo gem install dingbot
sudo gem install semantic_logger
```


## Usage

```
oceanpackage --workspace-path=/Users/ocean/Desktop/code/iOS/MyApp.xcworkspace --scheme=MyApp --configuration=Debug --archive-path=/Users/ocean/Documents/myipas --export-options-plist=/Users/ocean/Desktop/code/iOS/Company/MyApp/AdHocExportOptions.plist --company-name=MyCompany --fir-token=fir平台的token --change-log=测试一下 --oss-bucket-name=bucket名称 --oss-bucket-path=bucket路径 --oss-endpoint=oss的endpoint --ding-token=钉钉群机器人token --at-mobiles=需要@的人手机号
```

- `--workspace-path`: `.xcworkspace` 文件路径
- `--scheme`: `scheme` 
- `--configuration`: `Debug` 和 `Release`
- `--archive-path`: 生成的 `.xcarchive` 文件目录
- `--export-options-plist`: 打包用到的 `export-options` plist 文件路径
- `--company-name`: 公司名称，可以不填
- `--fir-token`: fir 平台的 token
- `--change-log`: 更新描述
- `--oss-bucket-name`: `oss bucket` 名称
- `--oss-bucket-path`: `oss bucket` 路径
- `--oss-endpoint`: `oss` 的 `endpoint`
- `--ding-token`: 钉钉群机器人的`token`
- `--at-mobiles`: 钉钉群需要 @ 的人手机号，多个用 `,` 拼接


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/ocean_package. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the OceanPackage project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/ocean_package/blob/master/CODE_OF_CONDUCT.md).
