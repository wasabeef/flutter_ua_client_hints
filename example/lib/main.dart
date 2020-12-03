import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ua_client_hints/ua_client_hints.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _ua;
  UserAgentData _uaData;
  Map<String, dynamic> _header;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    String ua;
    UserAgentData uaData;
    Map<String, dynamic> header;
    try {
      ua = await userAgent();
      uaData = await userAgentData();
      header = await userAgentClientHintsHeader();
    } on PlatformException {}

    setState(() {
      _ua = ua;
      _uaData = uaData;
      _header = header;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '## UserAgent',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('${_ua}'),
            //
            SizedBox(height: 24),
            //
            Text(
              '## UserAgentData',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('platform: ${_uaData?.platform}'),
            Text('platformVersion: ${_uaData?.platformVersion}'),
            Text('model: ${_uaData?.model}'),
            Text('brand: ${_uaData?.brand}'),
            Text('mobile: ${_uaData?.mobile}'),
            Text('device: ${_uaData?.device}'),
            Text('appName: ${_uaData?.package?.appName}'),
            Text('appVersion: ${_uaData?.package?.appVersion}'),
            Text('packageName: ${_uaData?.package?.packageName}'),
            Text('buildNumber: ${_uaData?.package?.buildNumber}'),
            //
            SizedBox(height: 24),
            //
            Text(
              '## User-Agent Client Hints',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            for (var i = 0; _header != null && i < _header.entries.length; i++)
              Text(
                  '${_header.keys.elementAt(i)}: ${_header.values.elementAt(i)}'),
          ],
        ),
      ),
    );
  }
}
