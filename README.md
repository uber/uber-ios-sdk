# Uber Rides iOS SDK (beta)

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
pod 'UberRides'
```

Then, run the following command to install the dependency:

```bash
$ pod install
```

### Carthage

Uber Rides is also available through [Carthage](https://github.com/Carthage/Carthage), a decentralized dependency manager that builds dependencies and provides you with binary frameworks, giving you full control over your project structure and setup.

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

Then drag the built `UberRides.framework` into your project.

### Manually Add Subprojects

You can integrate Uber Rides into your project manually without using a dependency manager.

Drag the `UberRides` framework project into your own and add the resource as an Embedded Binary, as well as a Target Dependency and Linked Framework (under Build Phases) in order to build on the simulator and on a device.

<p align="center">
  <img src="https://github.com/uber/rides-ios-sdk/blob/master/img/manual_install.png?raw=true" alt="Manually Install Framework"/>
</p>

### Configuring iOS 9.0

If you are compiling on iOS SDK 9.0, you will need to modify your application’s `plist` to handle Apple’s [new security changes](https://developer.apple.com/videos/wwdc/2015/?id=703) to the `canOpenURL` function.

```
<key>LSApplicationQueriesSchemes</key>
<array>                                           
<string>uber</string>
</array>
```

<p align="center">
  <img src="https://github.com/uber/rides-ios-sdk/blob/master/img/modify_plist.png?raw=true" alt="Modify App's plist"/>
</p>

This will allow the Uber iOS integration to properly identify and switch to the installed Uber application. If you are not on iOS SDK 9.0, then you are allowed to have up to 50 unique app schemes and do not need to modify your app’s `plist`.

## Example Usage

Import the library into your project:


```swift
// Swift
import UberRides
```

```objective-c
// Objective-C
@import UberRides;
```

Configure `RidesClient` with your registered Client ID. The end of `application (application, didFinishLaunchingWithOptions)` in your `AppDelegate` is a good place to do this:

```swift
// Swift
RidesClient.sharedInstance.configureClientID("YOUR_CLIENT_ID")
```

```objective-c
// Objective-C
[[RidesClient sharedInstance] configureClientID:@"YOUR_CLIENT_ID"];
```

You can add a Ride Request Button to your view like you would any other UIView:

```swift
// Swift
let button = RequestButton()
view.addSubview(button)
```

```objective-c
// Objective-C
RequestButton *button = [[RequestButton alloc] init];
[view addSubview:button];
```

This will create a request button with default behavior, with the pickup pin set to the user’s current location. The user will need to select a product and input additional information when they are switched over to the Uber application.

### Adding Paramters

We suggest passing additional parameters to make the Uber experience even more seamless for your users. For example, dropoff location parameters can be used to automatically pass the user’s destination information over to the driver:

```swift
// Swift
button.setProductID("abc123-productID")
button.setPickupLocation(latitude: "37.770", longitude: "-122.466", nickname: "California Academy of Sciences")
button.setDropoffLocation(latitude: "37.791", longitude: "-122.405", nickname: "Pier 39")
```

```objective-c
// Objective-C
[button setProductID:@"abc123-productID"];
[button setPickupLocationWithLatitude:@"37.770" longitude:@"-122.466" nickname:@"California Academy of Sciences" address:nil];
[button setDropoffLocationWithLatitude:@"37.791" longitude:@"-122.405" nickname:@"Pier 39" address:nil];
```

With all the necessary parameters set, pressing the button will seamlessly prompt a ride request confirmation screen.

### Color Style

The default color has a black background with white text:

```swift
// Swift
let button = RequestButton()
```

```objective-c
// Objective-C
RequestButton *button = [[RequestButton alloc] init];
```

For a button with a white background and black text:

```swift
// Swift
let button = RequestButton(.white)
```

```objective-c
// Objective-C
RequestButton *whiteRequestButton = [[RequestButton alloc] initWithColorStyle:RequestButtonColorStyleWhite];
```

## Example Apps

Example apps can be found in the `examples` folder. To run it, browse to the `examples` directory, run `pod install`, then open `SwiftSDK.xcworkspace` or `ObjcSDK.xcworkspace` in Xcode and run it.

Don’t forget to configure `RidesClient` with your Client ID in `AppDelegate.swift`.

<p align="center">
  <img src="https://github.com/uber/rides-ios-sdk/blob/master/img/example_app.png?raw=true" alt="Example App Screenshot"/>
</p>

## Getting help

Uber developers actively monitor the [Uber Tag](http://stackoverflow.com/questions/tagged/uber-api) on StackOverflow. If you need help installing or using the library, you can ask a question there. Make sure to tag your question with uber-api and ios!

For full documentation about our API, visit our [Developer Site](https://developer.uber.com/).

## Contributing

We :heart: contributions. If you’ve found a bug in the library or would like new features added, go ahead and open issues or pull requests against this repo. Write a test to show your bug was fixed or the feature works as expected.

## License

The Uber Rides iOS SDK is released under the MIT license. See the LICENSE file for more details.
