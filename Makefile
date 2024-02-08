.PHONY: deps
get:
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
	cd example && flutter run --target lib/main.dart

.PHONY: build-android
build-android:
	 cd example/ && flutter build apk --target lib/main.dart

.PHONY: build-ios
build-ios:
	cd example/ && flutter build ios --no-codesign --target lib/main.dart
