import 'package:flutter_test/flutter_test.dart';
import 'package:ua_client_hints/src/ua_parser.dart';

const _chromeOnAndroid =
    'Mozilla/5.0 (Linux; Android 14; Pixel 8) AppleWebKit/537.36 '
    '(KHTML, like Gecko) Chrome/124.0.0.0 Mobile Safari/537.36';
const _safariOnIphone =
    'Mozilla/5.0 (iPhone; CPU iPhone OS 17_4 like Mac OS X) '
    'AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Mobile/15E148 '
    'Safari/604.1';
const _chromeOnMac =
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 '
    '(KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36';
const _edgeOnWindows =
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
    '(KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0';
const _firefoxOnLinux =
    'Mozilla/5.0 (X11; Linux x86_64; rv:125.0) Gecko/20100101 Firefox/125.0';

void main() {
  group('parseBrowserName', () {
    test('detects Edge before Chrome', () {
      expect(parseBrowserName(_edgeOnWindows), 'Edge');
    });

    test('detects Chrome', () {
      expect(parseBrowserName(_chromeOnAndroid), 'Chrome');
    });

    test('detects Firefox', () {
      expect(parseBrowserName(_firefoxOnLinux), 'Firefox');
    });

    test('detects Safari only when Version/ token precedes Safari/', () {
      expect(parseBrowserName(_safariOnIphone), 'Safari');
      // Chrome user agents also contain "Safari/" but no "Version/" token.
      expect(parseBrowserName(_chromeOnMac), 'Chrome');
    });

    test('detects Opera via OPR token', () {
      expect(
        parseBrowserName('$_chromeOnMac OPR/110.0.0.0'),
        'Opera',
      );
    });

    test('falls back to Browser when nothing matches', () {
      expect(parseBrowserName('SomeUnknownAgent/1.0'), 'Browser');
    });
  });

  group('inferPlatform', () {
    test('prefers iOS from the user agent', () {
      expect(inferPlatform(_safariOnIphone, 'iPhone'), 'iOS');
    });

    test('detects Android from the user agent', () {
      expect(inferPlatform(_chromeOnAndroid, 'Linux armv8l'), 'Android');
    });

    test('uses the navigator platform for desktop systems', () {
      expect(inferPlatform(_chromeOnMac, 'MacIntel'), 'macOS');
      expect(inferPlatform(_edgeOnWindows, 'Win32'), 'Windows');
      expect(inferPlatform(_firefoxOnLinux, 'Linux x86_64'), 'Linux');
    });

    test('falls back to Web when nothing matches', () {
      expect(inferPlatform('Unknown', ''), 'Web');
    });
  });

  group('inferPlatformVersion', () {
    test('reads the Android version', () {
      expect(inferPlatformVersion(_chromeOnAndroid, 'Android'), '14');
    });

    test('reads and dots the iOS version', () {
      expect(inferPlatformVersion(_safariOnIphone, 'iOS'), '17.4');
    });

    test('reads and dots the macOS version', () {
      expect(inferPlatformVersion(_chromeOnMac, 'macOS'), '10.15.7');
    });

    test('reads the Windows NT version', () {
      expect(inferPlatformVersion(_edgeOnWindows, 'Windows'), '10.0');
    });

    test('returns empty when the platform has no pattern', () {
      expect(inferPlatformVersion(_firefoxOnLinux, 'Linux'), '');
    });
  });

  group('inferArchitecture', () {
    test('detects arm64', () {
      expect(
        inferArchitecture('Mozilla/5.0 (Linux; arm64) Chrome/124'),
        'arm64',
      );
    });

    test('detects arm', () {
      expect(inferArchitecture('Linux armv7l'), 'arm');
    });

    test('detects x86_64 from x64 and win64 tokens', () {
      expect(inferArchitecture(_edgeOnWindows), 'x86_64');
      expect(inferArchitecture('Intel Mac OS X x86_64'), 'x86_64');
    });

    test('detects x86', () {
      expect(inferArchitecture('Windows NT 10.0; i686'), 'x86');
    });

    test('returns empty when unknown', () {
      expect(inferArchitecture(_safariOnIphone), '');
    });
  });

  group('inferMobile', () {
    test('is true for mobile user agents', () {
      expect(inferMobile(_chromeOnAndroid), isTrue);
      expect(inferMobile(_safariOnIphone), isTrue);
    });

    test('is false for desktop user agents', () {
      expect(inferMobile(_chromeOnMac), isFalse);
      expect(inferMobile(_edgeOnWindows), isFalse);
    });
  });

  group('selectBrand', () {
    test('skips placeholder GREASE brands', () {
      final brands = <Map<String, dynamic>>[
        {'brand': 'Not A;Brand', 'version': '99'},
        {'brand': 'Chromium', 'version': '124'},
        {'brand': 'Google Chrome', 'version': '124'},
      ];
      expect(selectBrand(brands, 'fallback'), 'Chromium');
    });

    test('skips empty brand names', () {
      final brands = <Map<String, dynamic>>[
        {'brand': '', 'version': '1'},
        {'brand': 'Opera', 'version': '110'},
      ];
      expect(selectBrand(brands, 'fallback'), 'Opera');
    });

    test('uses the fallback when every brand is a placeholder', () {
      final brands = <Map<String, dynamic>>[
        {'brand': 'Not;A Brand', 'version': '8'},
        {'brand': '(Not(A:Brand', 'version': '99'},
      ];
      expect(selectBrand(brands, 'Chrome'), 'Chrome');
    });

    test('uses the fallback when the list is empty', () {
      expect(selectBrand(const [], 'Chrome'), 'Chrome');
    });
  });

  group('isPlaceholderBrand', () {
    test('matches known placeholders even with surrounding whitespace', () {
      expect(isPlaceholderBrand('  Not A;Brand '), isTrue);
      expect(isPlaceholderBrand('(Not(A:Brand'), isTrue);
    });

    test('does not match real brands', () {
      expect(isPlaceholderBrand('Google Chrome'), isFalse);
    });
  });

  group('coerceBrandList', () {
    test('keeps only map entries and copies them', () {
      final result = coerceBrandList(<dynamic>[
        {'brand': 'Chrome', 'version': '124'},
        'not a map',
        42,
      ]);
      expect(result, hasLength(1));
      expect(result.first['brand'], 'Chrome');
    });

    test('returns an empty list for non-list input', () {
      expect(coerceBrandList('nope'), isEmpty);
      expect(coerceBrandList(null), isEmpty);
    });
  });

  group('coerceString', () {
    test('returns the string form of a value', () {
      expect(coerceString(42), '42');
      expect(coerceString('hello'), 'hello');
    });

    test('uses the fallback for null or empty values', () {
      expect(coerceString(null, 'fallback'), 'fallback');
      expect(coerceString('', 'fallback'), 'fallback');
    });
  });

  group('coerceBool', () {
    test('passes through real bools', () {
      expect(coerceBool(true, false), isTrue);
      expect(coerceBool(false, true), isFalse);
    });

    test('treats non-zero numbers as true', () {
      expect(coerceBool(1, false), isTrue);
      expect(coerceBool(0, true), isFalse);
    });

    test('parses string booleans case-insensitively', () {
      expect(coerceBool('TRUE', false), isTrue);
      expect(coerceBool('false', true), isFalse);
    });

    test('uses the fallback for unrecognized values', () {
      expect(coerceBool(null, true), isTrue);
      expect(coerceBool(<int>[], false), isFalse);
    });
  });
}
