# kanbasu

[![Coverage Status](https://coveralls.io/repos/github/BugenZhao/kanbasu/badge.svg?branch=main&t=JNOXuu)](https://coveralls.io/github/BugenZhao/kanbasu?branch=main)
[![Test](https://github.com/BugenZhao/kanbasu/actions/workflows/test.yaml/badge.svg)](https://github.com/BugenZhao/kanbasu/actions/workflows/test.yaml)

Kanbasu is a third-party mobile App for Canvas LMS. It implements students' most-used functionalities,
and is tailored for SJTU open Canvas system.

## Key Features

* Enhanced activities view
* Full offline capability
* Download all files in one click
* Chat-like discussion view

<img src="https://user-images.githubusercontent.com/4198311/117810137-9b462680-b291-11eb-8cae-dbf40ec0c648.jpg" width="30%">
<img src="https://user-images.githubusercontent.com/4198311/117810168-a13c0780-b291-11eb-94c7-5048b2f255ee.PNG" width="30%">
<img src="https://user-images.githubusercontent.com/4198311/117810176-a305cb00-b291-11eb-81c9-340970657de3.PNG" width="30%">

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
