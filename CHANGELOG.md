## 1.3.0

**Bug fix**

[**BREAKING CHANGE**] [#101](https://github.com/wasabeef/flutter_ua_client_hints/pull/101)  Prefix UA with appName instead of brand by [@sgrodzicki](https://github.com/sgrodzicki).

```
Before:
 User-Agent: Apple/1.0.0 (iOS 17.2; iPhone; Simulator; x86)

After:
 User-Agent: SampleApp/1.0.0 (iOS 17.2; iPhone; Simulator; x86)
```

## 1.2.2

**Development**
- Update Kotlin kotlin-stdlib-jdk7 to kotlin-stdlib


## 1.2.1

**Development**
- Update Flutter to >=3.0.0
- Update Gradle plugins to v8


## 1.2.0

**Bug fix**
- Wrong brand name.

## 1.1.3

**Development**
- Migrate jCenter to MavenCentral for android apps.

## 1.1.2

**Feature**
- Change Android compileSdkVersion to 33
- Update Flutter to >=2.10.0

**Development**
- Update Flutter to 3.3.0
- Update Dart to 2.18.0

## 1.1.1

**Feature**
- Update Dart SDK to >=2.14.0
- Require Android minSdkVersion to 22

**Development**
- Replace effective_dart to flutter_lints

## 1.1.0

**Feature**
- Update Flutter to >=2.0.0
- Update Dart to >=2.12.0

## 1.0.2

**Bug Fix**
- Set Android minSdkVersion to 21.

## 1.0.0, 1.0.1

Initial release.

**Feature**
- userAgent() return String.
- userAgentData() return UserAgentData
- userAgentClientHintsHeader return Map

[Check API docs](https://pub.dev/documentation/ua_client_hints/latest/ua_client_hints/ua_client_hints-library.html)
