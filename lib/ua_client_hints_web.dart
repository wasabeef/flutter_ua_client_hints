import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:web/web.dart' as web;

import 'src/ua_parser.dart';

class UaClientHintsWeb {
  static _PackageData? _packageData;
  static Future<_PackageData>? _packageDataLoad;

  static void registerWith(Registrar registrar) {
    final channel = MethodChannel(
      'ua_client_hints',
      const StandardMethodCodec(),
      registrar,
    );

    final plugin = UaClientHintsWeb();
    channel.setMethodCallHandler(plugin.handleMethodCall);
  }

  Future<dynamic> handleMethodCall(MethodCall call) async {
    if (call.method == 'getInfo') {
      return _buildInfo();
    }

    throw MissingPluginException('No implementation found for ${call.method}');
  }

  Future<Map<String, dynamic>> _buildInfo() async {
    final navigator = web.window.navigator;
    final browserName = parseBrowserName(navigator.userAgent);
    final hints = await _loadHints(navigator, browserName);
    final packageData = await _loadPackageData();

    return <String, dynamic>{
      'platform': hints.platform,
      'platformVersion': hints.platformVersion,
      'architecture': hints.architecture,
      'model': hints.model,
      'brand': hints.brand,
      'version': packageData.appVersion,
      'mobile': hints.mobile,
      'device': hints.device,
      'appName': packageData.appName,
      'appVersion': packageData.appVersion,
      'packageName': packageData.packageName,
      'buildNumber': packageData.buildNumber,
    };
  }

  Future<_HintsData> _loadHints(
    web.Navigator navigator,
    String browserName,
  ) async {
    final navigatorObject = navigator as JSObject;
    final defaultPlatform = inferPlatform(
      navigator.userAgent,
      navigator.platform,
    );
    final defaultVersion = inferPlatformVersion(
      navigator.userAgent,
      defaultPlatform,
    );
    final defaultArchitecture = inferArchitecture(navigator.userAgent);
    final defaultMobile = inferMobile(navigator.userAgent);

    final userAgentDataValue = navigatorObject['userAgentData'];
    if (userAgentDataValue == null) {
      return _HintsData(
        brand: browserName,
        platform: defaultPlatform,
        platformVersion: defaultVersion,
        architecture: defaultArchitecture,
        model: '',
        device: '',
        mobile: defaultMobile,
      );
    }

    final userAgentData = userAgentDataValue as JSObject;

    final brands = coerceBrandList(_dartifyProperty(userAgentData, 'brands'));
    final mobileValue = _dartifyProperty(userAgentData, 'mobile');
    final platformValue = _dartifyProperty(userAgentData, 'platform');

    var brand = selectBrand(brands, browserName);
    var platform = coerceString(platformValue, defaultPlatform);
    var platformVersion = defaultVersion;
    var architecture = defaultArchitecture;
    var model = '';
    var device = '';
    final mobile = coerceBool(mobileValue, defaultMobile);

    try {
      final promise = userAgentData.callMethodVarArgs<JSPromise<JSAny?>>(
        'getHighEntropyValues'.toJS,
        <JSAny?>[
          <JSString>[
            'architecture'.toJS,
            'model'.toJS,
            'platformVersion'.toJS,
            'fullVersionList'.toJS,
          ].toJS,
        ],
      );

      final dartified = (await promise.toDart).dartify();
      if (dartified is! Map) {
        throw StateError('Unexpected userAgentData payload');
      }
      final values = Map<String, dynamic>.from(dartified);

      architecture = coerceString(values['architecture'], architecture);
      model = coerceString(values['model']);
      platformVersion = coerceString(
        values['platformVersion'],
        platformVersion,
      );

      final fullVersionBrands = coerceBrandList(values['fullVersionList']);
      brand = selectBrand(fullVersionBrands, brand);
    } catch (_) {
      // Fall back to the low-entropy data and parsed user agent values.
    }

    platform = platform.isEmpty ? defaultPlatform : platform;

    return _HintsData(
      brand: brand,
      platform: platform,
      platformVersion: platformVersion,
      architecture: architecture,
      model: model,
      device: device,
      mobile: mobile,
    );
  }

  Future<_PackageData> _loadPackageData() {
    if (_packageData != null) {
      return Future<_PackageData>.value(_packageData);
    }

    return _packageDataLoad ??= () async {
      try {
        final packageData = await _fetchPackageData();
        if (packageData.loadedFromVersionJson) {
          _packageData = packageData;
        }
        return packageData;
      } finally {
        _packageDataLoad = null;
      }
    }();
  }

  Future<_PackageData> _fetchPackageData() async {
    try {
      final baseUriString = web.document.baseURI;
      final baseUri = Uri.parse(
        baseUriString.isNotEmpty ? baseUriString : web.window.location.href,
      );
      final response = await _getString(
        baseUri.resolve('version.json').toString(),
      );
      final values = jsonDecode(response) as Map<String, dynamic>;
      final appName = coerceString(values['app_name'], web.document.title);
      final appVersion = coerceString(values['version']);
      final packageName = coerceString(values['package_name'], appName);

      return _PackageData(
        appName: appName,
        appVersion: appVersion,
        packageName: packageName,
        buildNumber: coerceString(values['build_number']),
        loadedFromVersionJson: true,
      );
    } catch (_) {
      final title = web.document.title;
      final fallbackName = title.isNotEmpty ? title : 'web';

      return _PackageData(
        appName: fallbackName,
        appVersion: '',
        packageName: fallbackName,
        buildNumber: '',
        loadedFromVersionJson: false,
      );
    }
  }
}

Future<String> _getString(String url) async {
  final response = await web.window.fetch(url.toJS).toDart;
  if (!response.ok) {
    throw StateError('GET $url failed with status ${response.status}.');
  }
  final text = await response.text().toDart;
  return text.toDart;
}

Object? _dartifyProperty(JSObject object, String property) {
  return object[property]?.dartify();
}

class _HintsData {
  const _HintsData({
    required this.brand,
    required this.platform,
    required this.platformVersion,
    required this.architecture,
    required this.model,
    required this.device,
    required this.mobile,
  });

  final String brand;
  final String platform;
  final String platformVersion;
  final String architecture;
  final String model;
  final String device;
  final bool mobile;
}

class _PackageData {
  const _PackageData({
    required this.appName,
    required this.appVersion,
    required this.packageName,
    required this.buildNumber,
    required this.loadedFromVersionJson,
  });

  final String appName;
  final String appVersion;
  final String packageName;
  final String buildNumber;
  final bool loadedFromVersionJson;
}
