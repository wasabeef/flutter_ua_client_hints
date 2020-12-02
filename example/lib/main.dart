import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ua_client_hints/ua_client_hints.dart';
import 'package:ua_client_hints/user_agent_data.dart';

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

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String ua;
    UserAgentData uaData;
    Map<String, dynamic> header;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      ua = await userAgent();
      uaData = await userAgentData();
      header = await userAgentClientHintsHeader();
    } on PlatformException {}

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

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
            Text('appName: ${_uaData?.app?.appName}'),
            Text('appVersion: ${_uaData?.app?.appVersion}'),
            Text('packageName: ${_uaData?.app?.packageName}'),
            Text('buildNumber: ${_uaData?.app?.buildNumber}'),
            Text('device: ${_uaData?.app?.device}'),
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
