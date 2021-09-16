[//]: # (Created by Jake Polacek on 07/31/2020)

# Maintainers Guide

This document describes tools, tasks and workflow that one needs to be familiar with in order to effectively maintain
this project. If you use this package within your own software as is but don't plan on modifying it, this guide is
**not** for you.

## Tools (optional)

The main tool that you need to be familiar with in order to maintain this file is Composer. Composer is used to install the dependencies needed to develop this library. The dependencies are installed in the vendor directory. In order to to install Composer if you do not already have it or you do not know how to use it, [follow these instructions](https:/getcomposer.org/download/).

## Tasks

Any files that remain to be implemented (as well as other design choices) can be [found here](design_choices.md). Otherwise, contact the team responsible for the library [here](htmlsanitizer-hack@slack-corp.com).

### Testing

Aside from using the built-in debugger in VSCode, debugging can be done by running either of two commands:
`bin/test` to run all test files, or
`vendor/bin/hacktest ${name}` where `${name}` is the name of the test file or test directory that you would like to run. 

### Releasing

To push a new release, follow these steps:

1. Make sure the main branch is up to date with all changes and has been tested, and the CI tests are passing.
2. Merge a new commit with the following changes:
- Add a description of all changes since the last release in CHANGELOG.md
- Add or update the "Latest releases" section in README.md with release highlights
3. Create a new GitHub release:
- Releases should always target the main branch
- Tag version and release title should both be in the format "v1.2.3", with the version matching the value in composer.json
- Copy your new section from CHANGELOG.md in the release description

## Workflow

### Versioning and Tags

This project uses semver for versioning.
Given a version number MAJOR.MINOR.PATCH, increment the:

1. MAJOR version when you make incompatible API changes,
2. MINOR version when you add functionality in a backwards compatible manner, and
3. PATCH version when you make backwards compatible bug fixes.

### Branches

All development should happen in feature branches. `main` should be ready for quick patching and publishing at all times.

### Issue Management

Labels are used to run issues through an organized workflow. Here are the basic definitions:

*  `bug`: A confirmed bug report. A bug is considered confirmed when reproduction steps have been
   documented and the issue has been reproduced.
*  `enhancement`: A feature request for something this package might not already do.
*  `docs`: An issue that is purely about documentation work.
*  `tests`: An issue that is purely about testing work.
*  `needs feedback`: An issue that may have claimed to be a bug but was not reproducible, or was otherwise missing some information.
*  `discussion`: An issue that is purely meant to hold a discussion. Typically the maintainers are looking for feedback in this issues.
*  `question`: An issue that is like a support request because the user's usage was not correct.
*  `semver:major|minor|patch`: Metadata about how resolving this issue would affect the version number.
*  `security`: An issue that has special consideration for security reasons.
*  `good first contribution`: An issue that has a well-defined relatively-small scope, with clear expectations. It helps when the testing approach is also known.
*  `duplicate`: An issue that is functionally the same as another issue. Apply this only if you've linked the other issue by number.

> You may want to add more labels for subsystems of your project, depending on how complex it is.

**Triage** is the process of taking new issues that aren't yet "seen" and marking them with a basic
level of information with labels. An issue should have **one** of the following labels applied:
`bug`, `enhancement`, `question`, `needs feedback`, `docs`, `tests`, or `discussion`.

Issues are closed when a resolution has been reached. If for any reason a closed issue seems
relevant once again, reopening is great and better than creating a duplicate issue.

## Everything else

When in doubt, find the other maintainers and ask.
