# Jobsity iOS coding challenge (João Pedro de Amorim)

## Introduction

This is the repository regarding Jobsity's iOS coding challenge.

https://user-images.githubusercontent.com/38262018/204124022-baf16ae0-10f4-4e28-88f9-ba1278f4c42b.mov

## Features done

### Mandatory Features

- [x] List all of the series contained in the API used by the paging scheme provided by the API.
- [x] Allow users to search series by name.
- [x] The listing and search views must show at least the name and poster image of the series.
- [x] After clicking on a series, the application should show the details of the series, showing the following information: Name, Poster, Days and time during which the series air, Genres, Summary, List of episodes separated by season
- [x] After clicking on an episode, the application should show the episode’s information, including: Name, Number, Season, Summary, Image (if there is one)

### Bonus features

- [x] Allow the user to save a series as a favorite.
- [x] Allow the user to delete a series from the favorites list.
- [x] Allow the user to browse their favorite series in alphabetical order, and click on one to see its details.

## Prerequisites (Building)

In order to build this application, you'll need [🛠 Xcode 14+]

The project itself doesn't use any external package/dependency, so in order to build on a simulator, the Xcode 14+ requirement is sufficient.

If you want to build it on device, iOS 16 is also a requirement (the deployment target of this project is set to iOS 16).
You'll also need a [Provisioning Profile] to run on device.

## Prerequisites (Development)

This project uses [Swiftlint] for linting in build scripts and [Fastlane] as a mean to build the project, test and lint it pre-commit and pre-push actions.

To install `swiftlint`, from the command line, do:

```bash
brew install swiftlint
```

**NOTE**: This is assuming [🍺 Homebrew] as your `MacOS` package manager of choice.

`fastlane` in this project is run through [Bundler]. To install `Bundler`, do:

```bash
gem install bundler
```

To install `fastlane` and its dependencies, from the project's root directory, do:

```bash
cd JobsityChallenge && bundle install
```

To run `fastlane` before every commit and push action, from the project's root directory, do:

```bash
chmod ug+x .git/hooks/*
echo "cd JobsityChallenge && bundle exec fastlane ci_check" > .git/hooks/pre-commit
echo "cd JobsityChallenge && bundle exec fastlane ci_check" > .git/hooks/pre-push
```

To add `swiftlint` as a build script of the project, on `Xcode`, under `JobsityChallenge>Build Phases`, add the following `Run Script Phase`:

```bash
export PATH="$PATH:/opt/homebrew/bin"
if which swiftlint > /dev/null; then
  swiftlint
else
  echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
fi
```

This already accounts for known issues with Apple Silicon (M1) Machines (see https://github.com/realm/SwiftLint#xcode)

## Project Architecture Overview

This project uses a very straightforward, simple and scalable approach of `MVVVM-C` (Model - View - ViewModel - Coordinator), using `SwiftUI` as its main UI framework.

The main target of the app is `JobsityChallenge`, but there's a unit test target as well, named 'JobsityChallengeTests`.

<!-- Links -->

[🛠 xcode 14+]: https://apps.apple.com/us/app/xcode/id497799835?mt=12
[🍺 homebrew]: https://brew.sh
[swiftlint]: https://github.com/realm/SwiftLint
[fastlane]: https://fastlane.tools/
[bundler]: https://bundler.io/
[provisioning profile]: https://developer.apple.com/documentation/appstoreconnectapi/profiles
