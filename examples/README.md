# Example Apps

## Universal Link Sample App

An example of how to authenticate with Uber services using an [auth code grant flow](https://auth0.com/docs/get-started/authentication-and-authorization-flow/authorization-code-flow). 

This sample app will demonstrate how to:
1. Build a universal link that will launch the native Uber app if installed
2. Make a /authorize request to Uber's backend and handle the auth code in the  response url
3. Exchange the auth code for a valid access token that can be used to make authenticated requests to Uber's backend services

### Setup
1. Add the sample app's redirect URI to your app's configuration in the [Uber Developer Portal](https://developer.uber.com/)

    `universallinkexample://app` 

2. Enter your app's ClientID found in the  in the sample app's Info.plist. This can also be done inside the sample app.
3. [Optional] Install the native Uber app on your device



## SDK Sample Apps

Requires Xcode 9

There are two sample apps, one written in Objective-C, and another written in Swift.

The sample apps use [Cocoapods](https://cocoapods.org) for package management. To set up and open the sample apps, navigate to either the `Obj-C SDK` or `Swift SDK` folder and run the following command:

```bash
$ pod install
```

After Cocoapods installs the Uber dependencies, open `xcworkspace`, and run!

For the Objective-C project, you may run into a compilation error. If so, click on your Pods project and select the `UberRides` target. Search for the `Swift Language Version` property, and change it to "Swift 4.0". Do the same thing for `UberCore`. [See Cocoapods issue](https://github.com/CocoaPods/CocoaPods/issues/6791).

