#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint korebotplugin.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'korebotplugin'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter plugin project.'
  s.description      = <<-DESC
A new Flutter plugin project.
                       DESC
  s.homepage         = 'https://kore.ai'
  s.license          = {:type => 'MIT', :file => 'LICENSE' }
  s.author           = {'Srinivas Vasadi' => 'srinivas.vasadi@kore.com'}
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '9.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
  
  #s.module_name = "KoreBotSDK"
  s.source_files = ['Classes/**/*','BotSDK/**/*.{h,m,swift}']
  s.resource_bundles = {
    'KoreBotSDK' => ["BotSDK/**/*.{xcassets}","BotSDK/**/*.{xcdatamodeld}", 'BotSDK/**/*.xib','BotSDK/**/*.json','BotSDK/**/*.lproj']
  }
    s.dependency 'Alamofire'
    s.dependency 'AlamofireImage'
    s.dependency 'Starscream'
    s.dependency 'ObjectMapper'
    s.dependency 'GhostTypewriter'
    s.dependency 'MarkdownKit'
    s.dependency 'DGCharts'
    s.dependency 'ObjectMapper'
    s.dependency 'AssetsPickerViewController'
    s.dependency 'SwiftUTI'
    s.dependency 'Emoji-swift'
end
