fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios appstore_profile

```sh
[bundle exec] fastlane ios appstore_profile
```

앱스토어용 프로비저닝 프로파일 설정

### ios development_profile

```sh
[bundle exec] fastlane ios development_profile
```

개발용 프로비저닝 프로파일 설정

### ios build

```sh
[bundle exec] fastlane ios build
```

개발 빌드 테스트

### ios archive

```sh
[bundle exec] fastlane ios archive
```

릴리즈 빌드 및 아카이브

### ios testflight_release

```sh
[bundle exec] fastlane ios testflight_release
```

TestFlight에 업로드

### ios appstore_release

```sh
[bundle exec] fastlane ios appstore_release
```

App Store에 제출

### ios update_github_release

```sh
[bundle exec] fastlane ios update_github_release
```

GitHub Release 업데이트 (App Store 승인 후)

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
