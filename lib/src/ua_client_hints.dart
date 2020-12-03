import 'dart:async';

import 'package:flutter/services.dart';

import 'package_data.dart';
import 'user_agent_data.dart';

/// e.g.. User-Agent: SampleApp/1.0.0 (Android 11; Pixel 4 XL; coral; arm64-v8a)
/// e.g.. User-Agent: SampleApp/1.0.0 (iOS 14.2; iPhone; iPhone13,4; arm64v8)
String _userAgent(Map<dynamic, dynamic> map) {
  return '${map['brand']}/${map['version']} (${map['platform']} ${map['platformVersion']}; ${map['model']}; ${map['device']}; ${map['architecture']})';
}

Future<String> userAgent() async {
  final map = await MethodChannel('ua_client_hints').invokeMethod('getInfo')
      as Map<dynamic, dynamic>;
  return _userAgent(map);
}

Future<UserAgentData> userAgentData() async {
  final map = await MethodChannel('ua_client_hints').invokeMethod('getInfo')
      as Map<dynamic, dynamic>;
  return UserAgentData(
      platform: map['platform'],
      platformVersion: map['platformVersion'],
      architecture: map['architecture'],
      model: map['model'],
      brand: map['brand'],
      version: map['version'],
      mobile: true,
      device: map['device'],
      package: PackageData(
        appName: map['appName'],
        appVersion: map['appVersion'],
        packageName: map['packageName'],
        buildNumber: map['buildNumber'],
      ));
}

Future<Map<String, String>> userAgentClientHintsHeader() async {
  final map = await MethodChannel('ua_client_hints').invokeMethod('getInfo')
      as Map<dynamic, dynamic>;
  return {
    'User-Agent': _userAgent(map),
    'Sec-CH-UA-Arch': map['architecture'],
    'Sec-CH-UA-Model': map['model'],
    'Sec-CH-UA-Platform': map['platform'],
    'Sec-CH-UA-Platform-Version': map['platformVersion'],
    'Sec-CH-UA': '"${map['appName']}"; v="${map['appVersion']}"',
    'Sec-CH-UA-Full-Version': map['appVersion'],
    'Sec-CH-UA-Mobile': map['mobile'] ? '?1' : '?0',
  };
}
