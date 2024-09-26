Pod::Spec.new do |s|
  s.name             = 'ua_client_hints'
  s.version          = '1.3.1'
  s.summary          = 'Provide User-Agent Client Hints plugin.'
  s.description      = <<-DESC
Provide User-Agent Client Hints plugin.
                       DESC
  s.homepage         = 'https://github.com/wasabeef/flutter_ua_client_hints'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Daichi Furiya' => 'dadadada.chop@gmail.com' }
  s.source           = { :http => 'https://github.com/wasabeef/flutter_ua_client_hints' }
  s.documentation_url = 'https://pub.dev/packages/ua_client_hints'
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '10.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.resource_bundles = { 'ua_client_hints_privacy' => ['PrivacyInfo.xcprivacy'] }
  s.swift_version = '5.0'
end
