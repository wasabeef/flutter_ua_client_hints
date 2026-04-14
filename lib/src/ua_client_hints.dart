import 'package:flutter/services.dart';

import 'package_data.dart';
import 'user_agent_data.dart';

const MethodChannel _channel = MethodChannel('ua_client_hints');

/// e.g.. User-Agent: SampleApp/1.0.0 (Android 11; Pixel 4 XL; coral; arm64-v8a)
/// e.g.. User-Agent: SampleApp/1.0.0 (iOS 14.2; iPhone; iPhone13,4; arm64v8)
String _userAgent(Map<dynamic, dynamic> map) {
  final appName = _stringValue(map['appName']);
  final version = _stringValue(map['version']);
  final platform = _stringValue(map['platform']);
  final platformVersion = _stringValue(map['platformVersion']);
  final model = _stringValue(map['model']);
  final brand = _stringValue(map['brand']);
  final device = _stringValue(map['device']);
  final architecture = _stringValue(map['architecture']);

  if (platform.isNotEmpty &&
      platformVersion.isNotEmpty &&
      model.isNotEmpty &&
      device.isNotEmpty &&
      architecture.isNotEmpty) {
    return '$appName/$version ($platform $platformVersion; $model; $device; $architecture)';
  }

  final compactDetails = <String>[
    <String>[platform, platformVersion]
        .where((value) => value.isNotEmpty)
        .join(' '),
    model.isNotEmpty ? model : brand,
    device,
    architecture,
  ].where((value) => value.isNotEmpty).join('; ');

  return '$appName/$version (${compactDetails.isEmpty ? 'Unknown' : compactDetails})';
}

Future<String> userAgent() async {
  final map = await _getInfo();
  return _userAgent(map);
}

Future<UserAgentData> userAgentData() async {
  final map = await _getInfo();
  return UserAgentData(
      platform: _stringValue(map['platform']),
      platformVersion: _stringValue(map['platformVersion']),
      architecture: _stringValue(map['architecture']),
      model: _stringValue(map['model']),
      brand: _stringValue(map['brand']),
      version: _stringValue(map['version']),
      mobile: _boolValue(map['mobile']),
      device: _stringValue(map['device']),
      package: PackageData(
        appName: _stringValue(map['appName']),
        appVersion: _stringValue(map['appVersion']),
        packageName: _stringValue(map['packageName']),
        buildNumber: _stringValue(map['buildNumber']),
      ));
}

Future<Map<String, String>> userAgentClientHintsHeader() async {
  final map = await _getInfo();
  return {
    'User-Agent': _userAgent(map),
    'Sec-CH-UA-Arch': _stringValue(map['architecture']),
    'Sec-CH-UA-Model': _stringValue(map['model']),
    'Sec-CH-UA-Platform': _stringValue(map['platform']),
    'Sec-CH-UA-Platform-Version': _stringValue(map['platformVersion']),
    'Sec-CH-UA':
        '"${_stringValue(map['appName'])}"; v="${_stringValue(map['appVersion'])}"',
    'Sec-CH-UA-Full-Version': _stringValue(map['appVersion']),
    'Sec-CH-UA-Mobile': _boolValue(map['mobile']) ? '?1' : '?0',
  };
}

Future<Map<dynamic, dynamic>> _getInfo() async {
  final dynamic info = await _channel.invokeMethod('getInfo');
  if (info is! Map) {
    throw PlatformException(
      code: 'invalid_response',
      message: 'ua_client_hints returned a non-map response.',
    );
  }
  return Map<dynamic, dynamic>.from(info);
}

String _stringValue(dynamic value) {
  return value?.toString() ?? '';
}

bool _boolValue(dynamic value) {
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0;
  }
  if (value is String) {
    return value.toLowerCase() == 'true';
  }
  return false;
}
