#
# Be sure to run `pod lib lint BitByteStream.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "BitByteStream"
  s.version          = "1.0.1"
  s.summary          = "conversion stream between bit and byte"
  s.description      = <<-DESC
                       This library provides the conversion stream between bit and byte.
                       DESC
  s.homepage         = "https://github.com/takfjt/BitByteStream"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Takahiro Fujita" => "takfjt@gmail.com" }
  s.source           = { :git => "https://github.com/takfjt/BitByteStream.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/takfjt'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
  #  'BitByteStream' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
