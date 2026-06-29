/// Pure helpers that derive User-Agent Client Hints values from a browser
/// user agent string and low entropy navigator data.
///
/// These functions contain no web interop, so they can be unit tested on the
/// Dart VM and shared by the Web plugin implementation.
library;

/// Parses a coarse browser name from a [userAgent] string.
String parseBrowserName(String userAgent) {
  const patterns = <String, String>{
    'Edg/': 'Edge',
    'OPR/': 'Opera',
    'Chrome/': 'Chrome',
    'Firefox/': 'Firefox',
  };

  for (final entry in patterns.entries) {
    if (RegExp(RegExp.escape(entry.key)).hasMatch(userAgent)) {
      return entry.value;
    }
  }

  if (RegExp(r'Version/[^\s]+.*Safari/').hasMatch(userAgent)) {
    return 'Safari';
  }

  return 'Browser';
}

/// Normalizes a dynamic `brands` payload into a list of string maps.
List<Map<String, dynamic>> coerceBrandList(dynamic value) {
  if (value is! List) {
    return const <Map<String, dynamic>>[];
  }

  return value
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList();
}

/// Returns the first non-placeholder brand name, or [fallback] when none
/// qualify.
String selectBrand(List<Map<String, dynamic>> brands, String fallback) {
  for (final brand in brands) {
    final current = coerceString(brand['brand']);
    if (current.isEmpty || isPlaceholderBrand(current)) {
      continue;
    }
    return current;
  }
  return fallback;
}

/// Whether [brand] is one of the intentionally meaningless "GREASE" brands
/// browsers inject to keep clients from relying on a fixed list.
bool isPlaceholderBrand(String brand) {
  const knownPlaceholderBrands = <String>{
    'Not A;Brand',
    'Not;A Brand',
    'Not_A Brand',
    '(Not(A:Brand',
    'Not)A;Brand',
  };

  return knownPlaceholderBrands.contains(brand.trim());
}

/// Infers the operating system from a [userAgent] and the navigator
/// [platform], falling back to `Web` when nothing matches.
String inferPlatform(String userAgent, String platform) {
  final normalizedUserAgent = userAgent.toLowerCase();
  final normalizedPlatform = platform.toLowerCase();

  if (normalizedUserAgent.contains('iphone') ||
      normalizedUserAgent.contains('ipad') ||
      normalizedUserAgent.contains('ipod')) {
    return 'iOS';
  }
  if (normalizedUserAgent.contains('android')) {
    return 'Android';
  }
  if (normalizedPlatform.contains('mac')) {
    return 'macOS';
  }
  if (normalizedPlatform.contains('win')) {
    return 'Windows';
  }
  if (normalizedPlatform.contains('linux')) {
    return 'Linux';
  }
  return 'Web';
}

/// Extracts a dotted platform version for [platform] from a [userAgent].
String inferPlatformVersion(String userAgent, String platform) {
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

/// Infers the CPU architecture from a [userAgent].
String inferArchitecture(String userAgent) {
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

/// Whether the [userAgent] describes a mobile device.
bool inferMobile(String userAgent) {
  return RegExp(
    r'Android|iPhone|iPad|iPod|Mobi',
    caseSensitive: false,
  ).hasMatch(userAgent);
}

/// Coerces a dynamic value to a non-null string, using [fallback] when the
/// value is missing or empty.
String coerceString(dynamic value, [String fallback = '']) {
  final text = value?.toString() ?? '';
  return text.isEmpty ? fallback : text;
}

/// Coerces a dynamic value to a bool, using [fallback] when the value cannot
/// be interpreted.
bool coerceBool(dynamic value, bool fallback) {
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
