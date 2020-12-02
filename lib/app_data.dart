import 'package:flutter/material.dart';

class AppData {
  const AppData({
    @required this.appName,
    @required this.appVersion,
    @required this.packageName,
    @required this.buildNumber,
    @required this.device,
  });

  final String appName;
  final String appVersion;
  final String packageName;
  final String buildNumber;
  final String device;
}
