fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew install fastlane`

# Available Actions
### build_for_testing
```
fastlane build_for_testing
```
Install dependencies, make build for testing
### run_app_tests
```
fastlane run_app_tests
```
Run tests on building app
### build_and_test
```
fastlane build_and_test
```
Build project and run tests
### generate_secret_config
```
fastlane generate_secret_config
```
Generate secret xcconfig

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
