#
# Be sure to run `pod lib lint CMUtils.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'CMUtils'
  s.version          = '0.1.0'
  s.summary          = '基础组件'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'http://134.175.230.26:9090/iOS_Compoent/CMUtils.git'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'xiaozhan' => 'Yu.Wang@zhan.com' }
  s.source           = { :git => 'http://134.175.230.26:9090/iOS_Compoent/CMUtils.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'CMUtils/Classes/**/*'
  
  s.subspec 'Hook' do |ss|
      ss.source_files = 'CMUtils/Classes/Hook/*.{h,m}'
  end
  s.subspec 'DateUtil' do |ss|
      ss.source_files = 'CMUtils/Classes/DateUtil/*.{h,m}'
  end
  s.subspec 'Device' do |ss|
      ss.source_files = 'CMUtils/Classes/Device/*.{h,m}'
  end
  s.subspec 'JsonHelper' do |ss|
    ss.source_files = 'CMUtils/Classes/JsonHelper/*.{h,m}'
  end
  s.subspec 'NSException' do |ss|
    ss.source_files = 'CMUtils/Classes/NSException/*.{h,m}'
  end
  s.subspec 'NSNumber' do |ss|
    ss.source_files = 'CMUtils/Classes/NSNumber/*.{h,m}'
  end
  s.subspec 'NSString' do |ss|
    ss.source_files = 'CMUtils/Classes/NSString/*.{h,m}'
    ss.frameworks = 'UIKit'
  end
  s.subspec 'RouterEvent' do |ss|
    ss.source_files = 'CMUtils/Classes/RouterEvent/*.{h,m}'
    ss.frameworks = 'UIKit'
  end
  s.subspec 'Security' do |ss|
    ss.source_files = 'CMUtils/Classes/Security/*.{h,m}'
    ss.dependency 'CMUtils/NSString'
  end
  s.subspec 'Storage' do |ss|
    ss.source_files = 'CMUtils/Classes/Storage/*.{h,m}'
  end
  s.subspec 'Timer' do |ss|
      ss.source_files = 'CMUtils/Classes/Timer/*.{h,m}'
  end
  s.subspec 'Privacy' do |ss|
      ss.source_files = 'CMUtils/Classes/Privacy/*.{h,m}'
      ss.frameworks = 'UIKit','AVFoundation','Photos','CoreLocation','NotificationCenter','UserNotifications'
  end
  
  # s.resource_bundles = {
  #   'CMUtils' => ['CMUtils/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
