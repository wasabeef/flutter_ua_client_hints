// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:convert';
import 'dart:html' as html;
import 'dart:js_util' as js_util;

import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

// TODO(ua_client_hints): Migrate this file to `package:web` + `dart:js_interop`
// when the package can raise its Dart SDK floor. Current `package:web` stable
// releases require Dart >= 3.4, while this package still supports Dart >= 2.17.
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
    final navigator = html.window.navigator;
    final browserName = _parseBrowserName(navigator.userAgent);
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
    html.Navigator navigator,
    String browserName,
  ) async {
    final defaultPlatform = _inferPlatform(navigator);
    final defaultVersion = _inferPlatformVersion(
      navigator.userAgent,
      defaultPlatform,
    );
    final defaultArchitecture = _inferArchitecture(navigator.userAgent);
    final defaultMobile = _inferMobile(navigator.userAgent);

    if (!js_util.hasProperty(navigator, 'userAgentData')) {
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

    final dynamic userAgentData =
        js_util.getProperty<dynamic>(navigator, 'userAgentData');

    final brands = _coerceBrandList(
      js_util.dartify(
        js_util.getProperty<Object?>(userAgentData, 'brands'),
      ),
    );
    final dynamic mobileValue = js_util.getProperty<Object?>(
      userAgentData,
      'mobile',
    );
    final dynamic platformValue = js_util.getProperty<Object?>(
      userAgentData,
      'platform',
    );

    var brand = _selectBrand(brands, browserName);
    var platform = _coerceString(platformValue, defaultPlatform);
    var platformVersion = defaultVersion;
    var architecture = defaultArchitecture;
    var model = '';
    var device = '';
    final mobile = _coerceBool(mobileValue, defaultMobile);

    try {
      final promise = js_util.callMethod<Object?>(
        userAgentData,
        'getHighEntropyValues',
        <Object?>[
          <String>[
            'architecture',
            'model',
            'platformVersion',
            'fullVersionList',
          ]
        ],
      );

      if (promise != null) {
        final resolved = await js_util.promiseToFuture<Object?>(promise);
        final dartified = js_util.dartify(resolved);
        if (dartified is! Map) {
          throw StateError('Unexpected userAgentData payload');
        }
        final values = Map<String, dynamic>.from(dartified);

        architecture = _coerceString(values['architecture'], architecture);
        model = _coerceString(values['model']);
        platformVersion = _coerceString(
          values['platformVersion'],
          platformVersion,
        );

        final fullVersionBrands = _coerceBrandList(values['fullVersionList']);
        brand = _selectBrand(fullVersionBrands, brand);
      }
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
      final baseUri = Uri.parse(
        html.document.baseUri ?? html.window.location.href,
      );
      final response = await html.HttpRequest.getString(
        baseUri.resolve('version.json').toString(),
      );
      final values = jsonDecode(response) as Map<String, dynamic>;
      final appName = _coerceString(values['app_name'], html.document.title);
      final appVersion = _coerceString(values['version']);
      final packageName = _coerceString(values['package_name'], appName);

      return _PackageData(
        appName: appName,
        appVersion: appVersion,
        packageName: packageName,
        buildNumber: _coerceString(values['build_number']),
        loadedFromVersionJson: true,
      );
    } catch (_) {
      final title = html.document.title;
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

String _parseBrowserName(String userAgent) {
  const patterns = <String, String>{
    'Edg/': 'Edge',
    'OPR/': 'Opera',
    'Chrome/': 'Chrome',
    'Firefox/': 'Firefox',
  };

  for (final entry in patterns.entries) {
    final match =
        RegExp('${RegExp.escape(entry.key)}([^\\s]+)').firstMatch(userAgent);
    if (match != null) {
      return entry.value;
    }
  }

  final safariMatch =
      RegExp(r'Version/([^\s]+).*Safari/').firstMatch(userAgent);
  if (safariMatch != null) {
    return 'Safari';
  }

  return 'Browser';
}

List<Map<String, dynamic>> _coerceBrandList(dynamic value) {
  if (value is! List) {
    return const <Map<String, dynamic>>[];
  }

  return value
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList();
}

String _selectBrand(List<Map<String, dynamic>> brands, String fallback) {
  for (final brand in brands) {
    final current = _coerceString(brand['brand']);
    if (current.isEmpty || _isPlaceholderBrand(current)) {
      continue;
    }
    return current;
  }
  return fallback;
}

bool _isPlaceholderBrand(String brand) {
  const knownPlaceholderBrands = <String>{
    'Not A;Brand',
    'Not;A Brand',
    'Not_A Brand',
    '(Not(A:Brand',
    'Not)A;Brand',
  };

  return knownPlaceholderBrands.contains(brand.trim());
}

String _inferPlatform(html.Navigator navigator) {
  final userAgent = navigator.userAgent.toLowerCase();
  final platform = (navigator.platform ?? '').toLowerCase();

  if (userAgent.contains('iphone') ||
      userAgent.contains('ipad') ||
      userAgent.contains('ipod')) {
    return 'iOS';
  }
  if (userAgent.contains('android')) {
    return 'Android';
  }
  if (platform.contains('mac')) {
    return 'macOS';
  }
  if (platform.contains('win')) {
    return 'Windows';
  }
  if (platform.contains('linux')) {
    return 'Linux';
  }
  return 'Web';
}

String _inferPlatformVersion(String userAgent, String platform) {
  final patterns = <String, RegExp>{
    'Android': RegExp(r'Android\s([0-9.]+)'),
    'iOS': RegExp(r'OS\s([0-9_]+)'),
    'macOS': RegExp(r'Mac OS X\s([0-9_]+)'),
    'Windows': RegExp(r'Windows NT\s([0-9.]+)'),
  };

  final match = patterns[platform]?.firstMatch(userAgent);
  if (match == null) {
    return '';
  }

  return (match.group(1) ?? '').replaceAll('_', '.');
}

String _inferArchitecture(String userAgent) {
  final normalized = userAgent.toLowerCase();
  if (normalized.contains('arm64') || normalized.contains('aarch64')) {
    return 'arm64';
  }
  if (normalized.contains('arm')) {
    return 'arm';
  }
  if (normalized.contains('x86_64') ||
      normalized.contains('win64') ||
      normalized.contains('x64')) {
    return 'x86_64';
  }
  if (normalized.contains('i686') || normalized.contains('i386')) {
    return 'x86';
  }
  return '';
}

bool _inferMobile(String userAgent) {
  return RegExp(
    r'Android|iPhone|iPad|iPod|Mobi',
    caseSensitive: false,
  ).hasMatch(userAgent);
}

String _coerceString(dynamic value, [String fallback = '']) {
  final text = value?.toString() ?? '';
  return text.isEmpty ? fallback : text;
}

bool _coerceBool(dynamic value, bool fallback) {
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0;
  }
  if (value is String) {
    return value.toLowerCase() == 'true';
  }
  return fallback;
}
