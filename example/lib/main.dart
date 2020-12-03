import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ua_client_hints/ua_client_hints.dart';

void main() async {
  // For Demo
  WidgetsFlutterBinding.ensureInitialized();

  final String ua = await userAgent();
  final UserAgentData uaData = await userAgentData();
  final Map<String, dynamic> header = await userAgentClientHintsHeader();

  print('## User-Agent ##');
  print('User-Agent: $ua');
  //
  //
  print('## User-Agent Client Hints ##');
  print('platform: ${uaData.platform}');
  print('platformVersion: ${uaData.platformVersion}');
  print('model: ${uaData.model}');
  print('brand: ${uaData.brand}');
  print('mobile: ${uaData.mobile}');
  print('device: ${uaData.device}');
  print('appName: ${uaData.package.appName}');
  print('appVersion: ${uaData.package.appVersion}');
  print('packageName: ${uaData.package.packageName}');
  print('buildNumber: ${uaData.package.buildNumber}');
  //
  //
  print('## User-Agent Client Hints ##');
  // header.forEach((key, value) => print('$key: $value'));
  print("User-Agent :${header['User-Agent']}");
  print("Sec-CH-UA-Arch :${header['Sec-CH-UA-Arch']}");
  print("Sec-CH-UA-Model :${header['Sec-CH-UA-Model']}");
  print("Sec-CH-UA-Platform :${header['Sec-CH-UA-Platform']}");
  print("Sec-CH-UA-Platform-Version :${header['Sec-CH-UA-Platform-Version']}");
  print("Sec-CH-UA :${header['Sec-CH-UA']}");
  print("Sec-CH-UA-Full-Version :${header['Sec-CH-UA-Full-Version']}");
  print("Sec-CH-UA-Mobile :${header['Sec-CH-UA-Mobile']}");

  return runApp(MaterialApp(
    home: Scaffold(body: Center(child: Text('User-Agent Client Hints'))),
  ));
}
