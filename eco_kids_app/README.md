# ecokids

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Firebase API keys setup

Do not commit Firebase API keys in source files.

Pass them at run/build time with `--dart-define`:

```bash
flutter run \
	--dart-define=FIREBASE_WEB_API_KEY=your_web_api_key \
	--dart-define=FIREBASE_ANDROID_API_KEY=your_android_api_key \
	--dart-define=FIREBASE_IOS_API_KEY=your_ios_api_key
```

For builds, use the same defines with `flutter build ...`.
