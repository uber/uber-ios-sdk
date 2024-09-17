# Uber iOS SDK

This library allows you to authenticate with Uber services and  interact with the Uber Rides API in your iOS application.

## Migrating to 2.0.0
Check the [Migration Guide](./documentation/migration-guide-2.0.0.md) for instructions on how to upgrade.

## Requirements

- iOS 14.0+
- Xcode 14.0+
- Swift 5.0+

## Installation

### Swift Package Manager
[Swift Package Manager](https://www.swift.org/documentation/package-manager/) is the preferred installation method. To install the Rides iOS SDK via SPM, add a package dependency to your project's Package.swift.

```
// swift-tools-version: 5.9

import PackageDescription

let package = Package(
  name: "My Project",
  dependencies: [
    .package(url: "https://github.com/uber/rides-ios-sdk.git", .upToNextMajor(from: "2.0.0"))
  ]
)
```


## Getting Started

### App Registration
Start by registering your application in the [Uber Developer's Portal](https://developer.uber.com/dashboard/create). Note the ClientID under the `Application ID` field.
    <p align="center">
    <img src="img/client_id.png?raw=true" alt="Request Buttons Screenshot"/>
</p>


### SDK Configuration

Next, configure your Xcode project with the registered application's information. Locate the **Info.plist** file for your application. Right-click this file and select **Open As > Source Code**

Add the following code snippet, replacing the placeholders within the square brackets (`[]`) with your app’s information from the developer dashboard. (Note: Do not include the square brackets)

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>uber</string>
    <string>uberauth</string>
    <string>ubereats</string>
    <string>uberdriver</string>
</array>
<key>Uber</key>
<dict>
    <key>ClientID</key>
    <string>[Client ID]</string>
    <key>DisplayName</key>
    <string>[App Name]</string>
</dict>
```

## Authenticating with Uber
See the [UberAuth documentation](./Sources/UberAuth/README.md) for information on how to authenticate your application's users with Uber.


## Rides API
See the [UberRides documentation](./Sources/UberRides/README.md) for information on how to interact with the Uber Rides API.



## Getting help

Uber developers actively monitor the [Uber Tag](http://stackoverflow.com/questions/tagged/uber-api) on StackOverflow. If you need help installing or using the library, you can ask a question there. Make sure to tag your question with uber-api and ios!

For full documentation about our API, visit our [Developer Site](https://developer.uber.com/).

## Contributing

We :heart: contributions. Found a bug or looking for a new feature? Open an issue and we'll respond as fast as we can. Or, better yet, implement it yourself and open a pull request! We ask that you include tests to show the bug was fixed or the feature works as expected.

**Note:** All contributors also need to fill out the [Uber Contributor License Agreement](http://t.uber.com/cla) before we can merge in any of your changes.

Please open any pull requests against the `develop` branch.

## License

The Uber Rides iOS SDK is released under the MIT license. See the LICENSE file for more details.
