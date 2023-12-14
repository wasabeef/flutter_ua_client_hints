# [User-Agent Client Hints for Flutter](https://pub.dev/packages/ua_client_hints)
<p align="center">
  <a href="https://pub.dev/packages/ua_client_hints">
    <img src="https://github.com/wasabeef/flutter_ua_client_hints/raw/main/art/ua_client_hints.png" width="100%/>
  </a>
</p>
<p align="center">
  <a href="https://pub.dev/packages/ua_client_hints">
    <img src="https://img.shields.io/pub/v/ua_client_hints.svg">
  </a>
  <a href="https://github.com/wasabeef/flutter_ua_client_hints/actions">
    <img src="https://github.com/wasabeef/flutter_ua_client_hints/workflows/Flutter%20CI/badge.svg" />
  </a>
  <a href="https://pub.dev/packages/effective_dart">
    <img src="https://img.shields.io/badge/style-effective_dart-40c4ff.svg" />
  </a>
  <a href="https://pub.dev/packages/ua_client_hints">
    <img src="https://img.shields.io/badge/-Null%20Safety-blue.svg" />
  </a>
</p>
                                                                           

## What's User-Agent Client Hints?

[User-Agent Client Hints](https://wicg.github.io/ua-client-hints/)  
[Improving user privacy and developer experience with User-Agent Client Hints](https://web.dev/user-agent-client-hints/)  
[User-Agent Client Hints Demo on Browser](https://user-agent-client-hints.glitch.me/?uach=UA-Arch&uach=UA-Full-Version&uach=UA-Mobile&uach=UA-Model&uach=UA-Platform-Version&uach=UA-Platform&uach=UA)  

|⬇️ Response Accept-CH|⬆️ Request header|⬆️ RequestExample value|Description|
|--|--|--|--|
|UA|Sec-CH-UA|"Chromium";v="84",<br>"Google Chrome";v="84"|List of browser brands and their significant version.|
|UA-Mobile|Sec-CH-UA-Mobile|?1|Boolean indicating if the browser is <br>on a mobile device (?1 for true) or not (?0 for false).|
|UA-Full-Version|Sec-CH-UA-Full-Version|"84.0.4143.2"|The complete version for the browser.|
|UA-Platform|Sec-CH-UA-Platform|"Android"|The platform for the device,<br>usually the operating system (OS).|
|UA-Platform-Version|Sec-CH-UA-Platform-Version|"10"|The version for the platform or OS.|
|UA-Arch|Sec-CH-UA-Arch|"ARM64"|The underlying architecture for the device.<br>While this may not be relevant to displaying the page,<br>the site may want to offer a download which defaults to the right format.|
|UA-Model|Sec-CH-UA-Model|"Pixel 3"|The device model.|

## [Installation](https://pub.dev/packages/ua_client_hints)

This plugin is set the [Null Safety](https://flutter.dev/docs/null-safety).

Add this to your package's `pubspec.yaml` file by running the following command

```shell
$ flutter pub add ua_client_hints
```

## Usage

### With [Dio](https://pub.dev/packages/dio)

Add to the request header.
```dart
class AppDio with DioMixin implements Dio {
  AppDio._([BaseOptions options]) {
    options = BaseOptions(
      baseUrl: 'https://wasabeef.jp',
    );

    this.options = options;
    interceptors.add(InterceptorsWrapper(
      onRequest: (options) async {
        // Add User-Agent Client Hints
        options.headers.addAll(await userAgentClientHintsHeader());
        return options;
      },
    ));
  }

  static Dio getInstance() => AppDio._();
}
```

### APIs
```dart
final String ua = await userAgent();

print('User-Agent: $ua');  // e.g.. 'SampleApp/1.0.0 (Android 11; Pixel 4 XL; coral; arm64-v8a)'
```

```dart
final UserAgentData uaData = await userAgentData();

print('platform:        ${uaData.platform}');              // e.g.. 'Android'
print('platformVersion: ${uaData.platformVersion}');       // e.g.. '10'
print('model:           ${uaData.model}');                 // e.g.. 'Pixel 4 XL'
print('architecture:    ${uaData.architecture}');          // e.g.. 'arm64-v8a'
print('brand:           ${uaData.brand}');                 // e.g.. 'Google'
print('mobile:          ${uaData.mobile}');                // e.g.. true
print('device:          ${uaData.device}');                // e.g.. 'coral'
print('appName:         ${uaData.package.appName}');       // e.g.. 'SampleApp'
print('appVersion:      ${uaData.package.appVersion}');    // e.g.. '1.0.0'
print('packageName:     ${uaData.package.packageName}');   // e.g.. 'jp.wasabeef.ua'
print('buildNumber:     ${uaData.package.buildNumber}');   // e.g.. '1'
```

```dart
final Map<String, dynamic> header = await userAgentClientHintsHeader();

print("Sec-CH-UA-Arch:             ${header['Sec-CH-UA-Arch']}");             // e.g.. 'arm64-v8a'
print("Sec-CH-UA-Model:            ${header['Sec-CH-UA-Model']}");            // e.g.. 'Pixel 4 XL'
print("Sec-CH-UA-Platform:         ${header['Sec-CH-UA-Platform']}");         // e.g.. 'Android'
print("Sec-CH-UA-Platform-Version: ${header['Sec-CH-UA-Platform-Version']}"); // e.g.. '10'
print("Sec-CH-UA:                  ${header['Sec-CH-UA']}");                  // e.g.. '"SampleApp"; v="1.0.0"'
print("Sec-CH-UA-Full-Version:     ${header['Sec-CH-UA-Full-Version']}");     // e.g.. '1.0.0'
print("Sec-CH-UA-Mobile:           ${header['Sec-CH-UA-Mobile']}");           // e.g.. '?1' (true) or '?0' (false)
```
