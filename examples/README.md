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

[TODO: Installation instructions]
