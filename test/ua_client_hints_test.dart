import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ua_client_hints/ua_client_hints.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('ua_client_hints');

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('userAgentData uses the platform mobile flag', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (methodCall) async {
      return <String, dynamic>{
        'platform': 'Web',
        'platformVersion': '17.4',
        'architecture': 'x86_64',
        'model': '',
        'brand': 'Chrome',
        'version': '1.2.3',
        'mobile': false,
        'device': 'Chrome',
        'appName': 'SampleApp',
        'appVersion': '1.2.3',
        'packageName': 'sample_app',
        'buildNumber': '42',
      };
    });

    final data = await userAgentData();

    expect(data.mobile, isFalse);
    expect(data.package.appVersion, '1.2.3');
  });

  test('userAgent omits empty values', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (methodCall) async {
      return <String, dynamic>{
        'platform': 'Web',
        'platformVersion': '',
        'architecture': '',
        'model': '',
        'brand': 'Chrome',
        'version': '1.2.3',
        'mobile': true,
        'device': 'Chrome',
        'appName': 'SampleApp',
        'appVersion': '1.2.3',
        'packageName': 'sample_app',
        'buildNumber': '42',
      };
    });

    expect(await userAgent(), 'SampleApp/1.2.3 (Web; Chrome)');
  });

  test('userAgent preserves the legacy format when all fields exist', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (methodCall) async {
      return <String, dynamic>{
        'platform': 'Android',
        'platformVersion': '14',
        'architecture': 'arm64-v8a',
        'model': 'Pixel 8',
        'brand': 'Google',
        'version': '1.2.3',
        'mobile': true,
        'device': 'husky',
        'appName': 'SampleApp',
        'appVersion': '1.2.3',
        'packageName': 'sample_app',
        'buildNumber': '42',
      };
    });

    expect(
      await userAgent(),
      'SampleApp/1.2.3 (Android 14; Pixel 8; husky; arm64-v8a)',
    );
  });

  test('userAgentClientHintsHeader serializes mobile flag', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (methodCall) async {
      return <String, dynamic>{
        'platform': 'Web',
        'platformVersion': '17.4',
        'architecture': 'x86_64',
        'model': '',
        'brand': 'Chrome',
        'version': '1.2.3',
        'mobile': false,
        'device': 'Chrome',
        'appName': 'SampleApp',
        'appVersion': '1.2.3',
        'packageName': 'sample_app',
        'buildNumber': '42',
      };
    });

    final headers = await userAgentClientHintsHeader();

    expect(headers['Sec-CH-UA-Mobile'], '?0');
    expect(headers['Sec-CH-UA'], '"SampleApp"; v="1.2.3"');
  });
}
