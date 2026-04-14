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
        'device': '',
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

  test('userAgent falls back to brand when device and model are empty',
      () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (methodCall) async {
      return <String, dynamic>{
        'platform': 'Web',
        'platformVersion': '',
        'architecture': '',
        'model': '',
        'brand': 'Google Chrome',
        'version': '1.2.3',
        'mobile': true,
        'device': '',
        'appName': 'SampleApp',
        'appVersion': '1.2.3',
        'packageName': 'sample_app',
        'buildNumber': '42',
      };
    });

    expect(await userAgent(), 'SampleApp/1.2.3 (Web; Google Chrome)');
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
        'device': '',
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

  test('userAgent uses unknown fallback when all details are empty', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (methodCall) async {
      return <String, dynamic>{
        'platform': '',
        'platformVersion': '',
        'architecture': '',
        'model': '',
        'brand': '',
        'version': '1.2.3',
        'mobile': false,
        'device': '',
        'appName': 'SampleApp',
        'appVersion': '1.2.3',
        'packageName': 'sample_app',
        'buildNumber': '42',
      };
    });

    expect(await userAgent(), 'SampleApp/1.2.3 (Unknown)');
  });

  test('userAgentClientHintsHeader exposes all expected keys and values',
      () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (methodCall) async {
      return <String, dynamic>{
        'platform': 'Web',
        'platformVersion': '17.4',
        'architecture': 'x86_64',
        'model': '',
        'brand': 'Google Chrome',
        'version': '1.2.3',
        'mobile': false,
        'device': '',
        'appName': 'SampleApp',
        'appVersion': '1.2.3',
        'packageName': 'sample_app',
        'buildNumber': '42',
      };
    });

    final headers = await userAgentClientHintsHeader();

    expect(headers, <String, String>{
      'User-Agent': 'SampleApp/1.2.3 (Web 17.4; Google Chrome; x86_64)',
      'Sec-CH-UA-Arch': 'x86_64',
      'Sec-CH-UA-Model': '',
      'Sec-CH-UA-Platform': 'Web',
      'Sec-CH-UA-Platform-Version': '17.4',
      'Sec-CH-UA': '"SampleApp"; v="1.2.3"',
      'Sec-CH-UA-Full-Version': '1.2.3',
      'Sec-CH-UA-Mobile': '?0',
    });
  });

  test('userAgentData throws a clear error on invalid plugin response',
      () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (methodCall) async => null);

    expect(
      userAgentData(),
      throwsA(
        isA<PlatformException>().having(
          (error) => error.code,
          'code',
          'invalid_response',
        ),
      ),
    );
  });
}
