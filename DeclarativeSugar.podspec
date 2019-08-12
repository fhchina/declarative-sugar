#
# Be sure to run `pod lib lint DeclarativeSugar.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'DeclarativeSugar'
  s.version          = '0.1.22'
  s.summary          = 'a Flutter-like declarative syntax sugar'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
a Flutter-like declarative syntax sugar based on Swift and UIStackView
                       DESC

  s.homepage         = 'https://github.com/slow-coding/DeclarativeSugar'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '623767307@qq.com' => '623767307@qq.com' }
  s.source           = { :git => 'https://github.com/slow-coding/DeclarativeSugar', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'DeclarativeSugar/Classes/**/*'
  s.swift_versions = '5'
  # s.resource_bundles = {
  #   'DeclarativeSugar' => ['DeclarativeSugar/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  #  s.dependency 'Then'
end
