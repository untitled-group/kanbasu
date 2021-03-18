# kanbasu

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## The Development Cycle

- Install Android Studio or VSCode (with Flutter support)
- Install Flutter from SJTUG mirror

```bash
git clone https://git.sjtu.edu.cn/sjtug/flutter-sdk flutter -b stable
```

- Checkout a new branch for new feature `git checkout -b some-new-feature`
- Do codegen (Do remember this step, otherwise compiler will complain on unexpected locations)

```bash
flutter pub run build_runner build
```

- Start development and test through Mobile or Desktop environment
  - Mobile: `flutter devices && flutter run -d device-id`
  - Desktop: Refer to [this article](https://flutter.dev/desktop) and `flutter run -d macos/windows`.
- Write unit tests (only for backend APIs, no need for UI components)
- Add changed files manually (Please don't add project-configuration-related files) and commit
- Lint (`flutter analyze`, `dart fix --dry-run && dart fix --apply`)
- Add changed files and commit again
- Push and submit PR, fill the PR title in format `module: what's changed`
