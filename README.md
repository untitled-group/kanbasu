# kanbasu

[![Coverage Status](https://coveralls.io/repos/github/BugenZhao/kanbasu/badge.svg?branch=main&t=JNOXuu)](https://coveralls.io/github/BugenZhao/kanbasu?branch=main)

A cross-platform App for Canvas LMS.

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
