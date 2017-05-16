#
# Be sure to run `pod lib lint ${POD_NAME}.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ReflectionSqlDatabase'
  s.version          = '1.0'
  s.summary          = 'SQLite library for Ios using reflection'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
SQLite library for Ios using reflection. The central ideia is to simplify the creation of DAO classes, and no need for complex configurations.
                       DESC

  s.homepage         = 'https://github.com/JoaoMarra/ReflectionIosDao'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  #s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'João Gabriel Silva Marra' => 'silvamarraster@gmail.com' }
  s.source           = { :git => 'https://github.com/JoaoMarra/ReflectionIosDao.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.3'

  s.source_files = 'Classes/**/*.{h,m}'
  
  # s.resource_bundles = {
  #   '${POD_NAME}' => ['${POD_NAME}/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit', 'sqlite3'
  # s.dependency 'AFNetworking', '~> 2.3'
end
