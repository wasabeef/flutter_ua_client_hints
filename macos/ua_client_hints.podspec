Pod::Spec.new do |s|
  s.name             = 'ua_client_hints'
  s.version          = '1.6.0'
  s.summary          = 'Provide User-Agent Client Hints plugin.'
  s.description      = <<-DESC
Provide native macOS support for User-Agent Client Hints in Flutter apps.
                       DESC
  s.homepage         = 'https://github.com/wasabeef/flutter_ua_client_hints'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.author           = { 'Daichi Furiya' => 'dadadada.chop@gmail.com' }
  s.source           = { :path => '.' }
  s.documentation_url = 'https://pub.dev/packages/ua_client_hints'
  s.source_files = 'Classes/**/*'
  s.dependency 'FlutterMacOS'
  s.platform = :osx, '10.14'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
