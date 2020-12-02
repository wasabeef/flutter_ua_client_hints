.PHONY: setup
setup:
	flutter channel beta
	flutter upgrade
	flutter pub get
	npm install
	gem update cocoapods
	cd ios/ && pod install && cd ..

.PHONY: dependencies
dependencies:
	flutter pub get

.PHONY: analyze
analyze:
	flutter analyze

.PHONY: format
format:
	flutter format lib/ example/lib/

.PHONY: format-analyze
format-analyze:
	flutter format --dry-run lib/ example/lib/
	flutter analyze

.PHONY: run
run-dev:
	flutter run --target example/lib/main.dart

.PHONY: build-android
build-android:
	flutter build apk --target example/lib/main.dart

.PHONY: build-ios
build-ios:
	flutter build ios --no-codesign --target example/lib/main.dart
