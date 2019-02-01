#
# Be sure to run `pod lib lint HappyMVVM.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'HappyMVVM'
  s.version          = '0.2.1'
  s.summary          = 'HappyMVVM is a good library to write ui'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
HappyMVVM is a good library to write ui.
                       DESC

  s.homepage         = 'https://github.com/scorplot/HappyMVVM'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'scorplot' => '1@1.com' }
  s.source           = { :git => 'https://github.com/scorplot/HappyMVVM.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'HappyMVVM/Classes/**/*'
  
  # s.resource_bundles = {
  #   'HappyMVVM' => ['HappyMVVM/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'TableViewArray'
  s.dependency 'CollectionViewArray'
  s.dependency 'TaskEnginer'
  s.dependency 'CCUIModel'
  #s.dependency 'MJRefresh'
  s.dependency 'RealReachability'
end
