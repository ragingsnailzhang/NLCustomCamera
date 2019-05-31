#
# Be sure to run `pod lib lint NLCustomCamera.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'NLCustomCamera'
  s.version          = '0.1.1'
  s.summary          = '自定义相机.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/wzyinglong/NLCustomCamera'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'wzyinglong' => 'wz_yinglong@163.com' }
  s.source           = { :git => 'https://github.com/wzyinglong/NLCustomCamera.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'
  s.requires_arc = true

  s.source_files = 'NLCustomCamera/Classes/**/*'
  
  s.resource_bundles = {
    'NLCustomCamera' => ['NLCustomCamera/Assets/**/*']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking'
  s.dependency 'GPUImage', '~> 0.1.7'
  s.dependency 'TZImagePickerController'
  s.dependency 'Masonry'
  s.dependency 'ZFPlayer', '~> 2.1.6'
  s.dependency 'MJExtension', '~> 3.0.13'
  s.dependency 'ReactiveObjC'
end
