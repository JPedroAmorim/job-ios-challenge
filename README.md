# Jobsity iOS coding challenge (João Pedro de Amorim)

## Introduction

This is the repository regarding Jobsity's iOS coding challenge.

## Prerequisites (Development)

This project uses `swiftlint` for linting in build scripts and `fastlane` as a mean to build the project, test and lint it pre-commit and pre-push actions.

To install `swiftlint`, from the command line, do:

```bash
brew install swiftlint
```

NOTE: This is assuming `Homebrew` as your MacOS package manager of choice.

`fastlane` in this project is run through `Bundle`. To install `Bundle`, do:

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
