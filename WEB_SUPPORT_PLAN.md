# Web Support Plan

## Goal

`ua_client_hints` に Web platform support を追加し、既存の public API をできるだけ維持したまま、Flutter Web でも `userAgent()`, `userAgentData()`, `userAgentClientHintsHeader()` を利用できる状態にする。

関連:

- Issue: [#132 Web Support](https://github.com/wasabeef/flutter_ua_client_hints/issues/132)
- Related PR: [#141 feat: add macOS support](https://github.com/wasabeef/flutter_ua_client_hints/pull/141)

## Current State

- 現状の public API は `MethodChannel('ua_client_hints')` 前提で実装されている。
- plugin metadata には `android`, `ios` のみが定義されており、`web` は未登録。
- `userAgentData()` で `mobile: true` が hardcode されているため、platform 実装の戻り値と public API が不整合になる。
- CI は Android build のみで、Web build / Web test の検証導線がない。

主要ファイル:

- [lib/src/ua_client_hints.dart](/Users/a12622/git/flutter_ua_client_hints/lib/src/ua_client_hints.dart:1)
- [pubspec.yaml](/Users/a12622/git/flutter_ua_client_hints/pubspec.yaml:1)
- [example/lib/main.dart](/Users/a12622/git/flutter_ua_client_hints/example/lib/main.dart:1)
- [.github/workflows/build.yml](/Users/a12622/git/flutter_ua_client_hints/.github/workflows/build.yml:1)

## Recommended Approach

既存 API を壊さないことを優先し、package-separated federated plugin へ全面移行するのではなく、同一 package 内に Web plugin 実装を追加する。

この方針を採る理由:

- 差分を最小化できる
- Android / iOS 実装との整合を保ちやすい
- 既存利用者に API migration を要求しない
- Flutter docs でも既存 plugin への Web 追加は `flutter create --template=plugin --platforms=web .` の形が前提

## Design Notes

### 1. API compatibility

既存の以下 API は維持する。

- `Future<String> userAgent()`
- `Future<UserAgentData> userAgentData()`
- `Future<Map<String, String>> userAgentClientHintsHeader()`

### 2. Web implementation strategy

Web では Dart 実装の plugin を追加し、`registerWith(Registrar)` で `ua_client_hints` channel を登録する。

取得方針:

- `navigator.userAgentData` が利用可能な場合
  - low entropy: `brands`, `mobile`, `platform`
  - high entropy: `architecture`, `model`, `platformVersion`, `fullVersionList`
- `navigator.userAgentData` が使えない場合
  - `navigator.userAgent` と `navigator.platform` に fallback
  - 取得できない項目は空文字で返す

### 3. App metadata on Web

Web では native のように bundle metadata が直接取れないため、Flutter Web の build 生成物である `version.json` を利用する。

`version.json` には以下が入る:

- `app_name`
- `version`
- `build_number`
- `package_name`

想定利用:

- `appName` <- `app_name`
- `appVersion` <- `version`
- `buildNumber` <- `build_number`
- `packageName` <- `package_name`

### 4. Semantics gap on Web

Web では `brand` が native の `manufacturer` 相当ではなく、browser brand に近い意味になる。

そのため README では以下を明記する。

- mobile / desktop では `brand` は device vendor 寄り
- web では `brand` は browser brand として返ることがある

### 5. Browser support caveat

`navigator.userAgentData` と `getHighEntropyValues()` は限定的サポートのため、Web 実装は fallback 前提にする。

結果として:

- Chrome 系では比較的豊富な値が返る
- Safari / Firefox 系では空文字や縮退値が混ざる可能性がある

## Work Breakdown

### Phase 1. Shared bug fix

目的:

- Web と macOS の両方に効く既存不整合を先に解消する

作業:

- [lib/src/ua_client_hints.dart](/Users/a12622/git/flutter_ua_client_hints/lib/src/ua_client_hints.dart:20) の `mobile: true` を `mobile: map['mobile']` に変更

完了条件:

- `UserAgentData.mobile` が platform 実装の返却値と一致する

### Phase 2. Plugin metadata update

目的:

- package を Web plugin として認識させる

作業:

- [pubspec.yaml](/Users/a12622/git/flutter_ua_client_hints/pubspec.yaml:23) に `web` platform を追加
- 必要な依存関係を追加
  - `flutter_web_plugins`
  - Web 実装で必要な browser access 用 dependency

検討事項:

- SDK 下限はなるべく現行維持
- 不要な major dependency update は避ける

完了条件:

- `flutter pub get` 後に package が Web plugin として解決される

### Phase 3. Web plugin implementation

目的:

- `getInfo` を Web でも返せるようにする

想定追加ファイル:

- `lib/ua_client_hints_web.dart` もしくは template に沿った Web 実装ファイル

作業:

- `registerWith(Registrar registrar)` を実装
- `MethodChannel` 経由で `getInfo` を処理
- browser から以下を取得
  - `platform`
  - `platformVersion`
  - `architecture`
  - `model`
  - `brand`
  - `version`
  - `mobile`
  - `device`
- `version.json` から以下を取得
  - `appName`
  - `appVersion`
  - `packageName`
  - `buildNumber`

実装ルール:

- 取得失敗時は例外で落とすよりも、縮退値で返す
- `null` を public map に漏らさない
- `Sec-CH-UA-Mobile` のような header 生成に必要な key は必ず返す

完了条件:

- `flutter run -d chrome` で example が起動し、3 API が例外なく呼べる

### Phase 4. Example update

目的:

- Web で実際に確認できるサンプルを用意する

作業:

- `example` に Web assets を追加
- sample app が Chrome で起動できる状態にする
- 可能なら表示内容を Web でも確認しやすい形に保つ

補足:

- 現在の example は console print 中心なので、UI は最小変更でよい

完了条件:

- `example` が `flutter run -d chrome` で起動できる

### Phase 5. Tests

目的:

- regression を防ぐ

作業候補:

- package unit test
  - shared Dart ロジックのテスト
  - header 生成ロジックのテスト
- web integration test
  - Chrome 上で plugin 呼び出し
  - 返却値が非空または期待した key を持つことを確認

最低限の確認項目:

- `userAgent()` が非空文字列を返す
- `userAgentData()` が例外なく返る
- `userAgentClientHintsHeader()` が主要 key を持つ

### Phase 6. README / CHANGELOG

目的:

- 利用者に Web support の仕様差分を伝える

作業:

- [README.md](/Users/a12622/git/flutter_ua_client_hints/README.md:1) に Web support を追記
- browser support caveat を追記
- `brand`, `model`, `architecture` が browser により空になる可能性を追記
- [CHANGELOG.md](/Users/a12622/git/flutter_ua_client_hints/CHANGELOG.md:1) に Web support を追加

完了条件:

- 利用者が Web の制約を README だけで把握できる

### Phase 7. CI update

目的:

- PR 時に Web regression を検出できるようにする

作業:

- [.github/workflows/build.yml](/Users/a12622/git/flutter_ua_client_hints/.github/workflows/build.yml:1) に Web build を追加
- 候補:
  - `flutter build web`
  - 余力があれば Chrome integration test

推奨順:

- まず `flutter build web`
- 安定したら integration test を追加

完了条件:

- CI で Web build failure を検知できる

## Suggested Commit Split

### Commit 1. Shared fix

- `mobile: true` hardcode 修正

### Commit 2. Web support

- pubspec metadata 更新
- Web plugin 実装
- example Web 対応

### Commit 3. Documentation and CI

- README
- CHANGELOG
- CI

## Risks

### Risk 1. Browser capability variance

内容:

- UA Client Hints は browser により取得可能な項目が異なる

対策:

- fallback 実装
- README に制約を明記
- test は「完全一致」より「存在保証」に寄せる

### Risk 2. Web app metadata retrieval

内容:

- `appVersion` などをどこから取るかが native と異なる

対策:

- `version.json` 利用を標準経路とする
- 取得失敗時の縮退値を定義する

### Risk 3. SDK / dependency drift

内容:

- template そのまま取り込みで SDK 下限や lint が大きく上がる可能性がある

対策:

- 生成物を丸ごと入れず、必要最小限だけ手で反映する

## Definition of Done

- `ua_client_hints` が Web platform を宣言している
- Chrome 上で example が起動する
- 3 つの public API が Web で呼べる
- 既存 Android / iOS 挙動を壊していない
- `UserAgentData.mobile` の不整合が解消されている
- README / CHANGELOG / CI が更新されている

## References

- Flutter docs: [Developing packages & plugins](https://docs.flutter.dev/packages-and-plugins/developing-packages)
- Flutter API: [Registrar class](https://api.flutter.dev/flutter/flutter_web_plugins/Registrar-class.html)
- MDN: [Navigator.userAgentData](https://developer.mozilla.org/en-US/docs/Web/API/Navigator/userAgentData)
- MDN: [NavigatorUAData.getHighEntropyValues()](https://developer.mozilla.org/en-US/docs/Web/API/NavigatorUAData/getHighEntropyValues)
