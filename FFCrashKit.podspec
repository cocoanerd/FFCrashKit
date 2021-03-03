#
# Be sure to run `pod lib lint FFCrashKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'FFCrashKit'
  s.version          = '0.1.0'
  s.summary          = 'FFCrashKit is used to protect crash of iOS project'

# This description is used to generate tags and imFFove search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'FFCrashKit is used to protect crash of iOS project!'

  s.homepage         = 'git@github.com:cocoanerd/FFCrashKit.git'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '张慧芳' => 'cocoanerd@163.com' }
  s.source           = { :git => 'git@github.com:cocoanerd/FFCrashKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.public_header_files = 'FFCrashKit/FFCrashKit.h'
  s.source_files = 'FFCrashKit/FFCrashKit.h'
  
  s.subspec 'HeaderFiles' do |ss|
    ss.public_header_files = 'FFCrashKit/HeaderFiles/FFSwizzle.h'
    ss.source_files = 'FFCrashKit/HeaderFiles/FFSwizzle.h'
  end
  
  s.subspec 'CrashReport' do |ss|
    ss.public_header_files = 'FFCrashKit/CrashReport/FFCrashReport.h'
    ss.source_files = 'FFCrashKit/CrashReport/FFCrashReport.{h,m}'
    ss.dependency 'FFCrashKit/HeaderFiles'
    ss.dependency 'FFCrashKit/Model'
  end
  
  s.subspec 'Manager' do |ss|
    ss.public_header_files = 'FFCrashKit/Manager/FFCrashRegeister.h'
    ss.source_files = 'FFCrashKit/Manager/FFCrashRegeister.{h,m}'
    ss.dependency 'FFCrashKit/UIFoundation'
    ss.dependency 'FFCrashKit/Model'
    ss.dependency 'FFCrashKit/CrashReport'
  end
  
  s.subspec 'Model' do |ss|
    ss.public_header_files = 'FFCrashKit/Model/FFCrashModel.h'
    ss.source_files = 'FFCrashKit/Model/FFCrashModel.{h,m}'
  end
  
  s.subspec 'UIFoundation' do |ss|
    ss.source_files = 'FFCrashKit/UIFoundation/*'
    ss.dependency 'FFCrashKit/Model'
    ss.dependency 'FFCrashKit/CrashReport'
    ss.dependency 'FFCrashKit/HeaderFiles'
  end
  # s.resource_bundles = {
  #   'FFCrashKit' => ['FFCrashKit/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
