# Uber Rides iOS SDK

This Swift library allows you to integrate Uber into your iOS app.

## Requirements

- iOS 8.0+
- Xcode 7.1+

## Getting Started

Before using this SDK, register your application on the [Uber Developer Site](https://developer.uber.com/dashboard)

### CocoaPods

The Uber Rides iOS SDK is a CocoaPod written in Swift. [CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate Uber Rides into your Xcode project, add it to your `Podfile`:

```ruby
pod 'Alamofire'
```

Then, run the following command to install the dependency:

```bash
$ pod install
```

### Carthage

Uber Rides is also available through [Carthage](https://github.com/Carthage/Carthage), a decentralized dependency manager that builds dependencies and provides you with binary frameworks, giving you fill control over your project structure and setup.

Install Carthage with [Homebrew](http://brew.sh/):

```bash
$ brew update
$ brew install carthage
```

To integrate Uber Rides into your Xcode project, add it to your `Cartfile`:

```ogdl
github "uber/rides-ios-sdk"
```

Build the framework:

```bash
$ carthage
```

Then drag the built `Rides.framework` into your project.

### Manually Add Subprojects

You can integrate Uber Rides into your project manually without using a dependency manager.

Drag the `Rides` framework project into your own and add the resource as an Embedded Binary, as well as a Target Dependency and Linked Framework (under Build Phases) in order to build on the simulator and on a device.

![Alt text](/img/manual_install.png?raw=true "Build Phases Screenshot")

### Configuring iOS 9.0

If you are compiling on iOS SDK 9.0, you will need to modify your application’s `plist` to handle Apple’s [new security changes](https://developer.apple.com/videos/wwdc/2015/?id=703) to the `canOpenURL` function.

```
<key>LSApplicationQueriesSchemes</key>
<array>                                           
<string>uber</string>
</array>
```

![Alt text](/img/modify_plist.png?raw=true "Modify App's plist")

This will allow the Uber iOS integration to properly identify and switch to the installed Uber application. If you are not on iOS SDK 9.0, then you are allowed to have up to 50 unique app schemes and do not need to modify your app’s `plist`.

## Example Usage

Import the library into your project:

```swift
import Rides
```

Configure `RidesClient` with your registered Client ID. The end of `application (application, didFinishLaunchingWithOptions)` in your `AppDelegate` is a good place to do this:

```swift
RidesClient.sharedInstance.setClientID("YOUR_CLIENT_ID")
```

You can add a Ride Request Button to your view like you would any other UIView:

```swift
let requestButton = RequestButton()
view.addSubview(requestButton)
```

This will create a request button with default behavior, with pickup pin set to the user’s current location. The user will need to select a product and input additional information when they are switched over to the Uber application.

### Adding Paramters

We suggest passing additional parameters to make the Uber experience even more seamless for your users. For example, dropoff location parameters can be used to automatically pass the user’s destination information over to the driver:

```swift
let requestButton = RequestButton()
requestButton.setProductID(“abc123-productID”)
requestButton.setPickupLocation(latitude: “37.770”, longitude: “-122.466”, nickname: “California Academy of Sciences”)
requestButton.setDropoffLocation(latitude: “37.791”, longitude: “-122.405”, nickname: “Pier 39”)
view.addSubview(requestButton)
```

With all the necessary parameters set, pressing the button will seamlessly prompt a ride request confirmation screen.

### Color Style

The default color has a black background with white text:

```swift
let requestButton = RequestButton()
```

For a button with a white background and black text:

```swift
let requestButton = RequestButton(.white)
```

## Example Apps

Example apps can be found in the `examples` folder. To run it, browse to the `examples` directory, run `pod install`, then open `SwiftSDK.xcworkspace` or `ObjcSDK.xcworkspace` in Xcode and run it.

Don’t forget to configure `RidesClient` with your Client ID in `AppDelegate.swift`.

![Alt text](/img/example_app.png?raw=true "Example App Screenshot")

## Getting help

Uber developers actively monitor the [Uber Tag](http://stackoverflow.com/questions/tagged/uber-api) on StackOverflow. If you need help installing or using the library, you can ask a question there. Make sure to tag your question with uber-api and python!

For full documentation about our API, visit our [Developer Site](https://developer.uber.com/v1/endpoints/).

## Contributing

We love contributions. If you’ve found a bug in the library or would like new features added, go ahead and open issues or pull requests against this repo. Write a test to show your bug was fixed or the feature works as expected.

## License

Uber Rides is released under the MIT license. See the LICENSE file for more details.