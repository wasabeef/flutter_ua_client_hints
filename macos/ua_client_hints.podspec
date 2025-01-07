Pod::Spec.new do |s|
  s.name             = 'ua_client_hints'
  s.version          = '0.0.1'
  s.summary          = 'User-Agent Client Hints for Flutter'
  s.description      = <<-DESC
A Flutter plugin for getting User-Agent Client Hints information.
                       DESC
  s.homepage         = 'https://github.com/wasabeef/flutter_ua_client_hints'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.platform = :osx, '10.11'
  
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
  
  s.dependency 'FlutterMacOS'
end 