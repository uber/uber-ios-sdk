# Uber Rides iOS SDK (beta)

This [Swift library] (https://developer.apple.com/library/ios/documentation/General/Reference/SwiftStandardLibraryReference/) allows you to integrate Uber into your iOS app.

## Requirements

- iOS 8.0+
- Xcode 7.1+

## Getting Started

Before using this SDK, register your application on the [Uber Developer Site](https://developer.uber.com/dashboard/create).

### CocoaPods

The Uber Rides iOS SDK is a CocoaPod written in Swift. [CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate Uber Rides into your Xcode project, navigate to the directory that contains your project and create a new **Podfile** with `pod init` or open an existing one, then add `pod 'UberRides'` to the main loop. If you are using the Swift SDK, make sure to add the line `use_frameworks!`.

```ruby
use_frameworks!

target 'Your Project Name' do
pod 'UberRides'
end
```

Then, run the following command to install the dependency:

```bash
$ pod install
```

For Objective-C projects, set the **Embedded Content Contains Swift Code** flag in your project to **Yes** (found under **Build Options** in the **Build Phases** tab).

### Carthage

Uber Rides is also available through [Carthage](https://github.com/Carthage/Carthage), a decentralized dependency manager that builds dependencies and provides you with binary frameworks, giving you full control over your project structure and setup.

Install Carthage with [Homebrew](http://brew.sh/):

```bash
$ brew update
$ brew install carthage
```

To integrate Uber Rides into your Xcode project, navigate to the directory that contains your project and create a new **Cartfile** with `touch Cartfile` or open an existing one, then add the following line:

```
github "uber/rides-ios-sdk"
```

Build the framework:

```bash
$ carthage update
```

Now add the `UberRides.framework` (in `Carthage/Build/iOS`) as a Linked Framework in Xcode (See the **Linked Frameworks and Libraries** section under the **General** tab of your project target). 

Then, on your application targets' **Build Phases** tab, click the '+' button and choose **New Run Script Phase**. Add the run script `/usr/local/bin/carthage copy-frameworks` and add the path to the UberRides framework under **Input Files**: `$(SRCROOT)/Carthage/Build/iOS/UberRides.framework`.

![Screenshot](/img/carthage_script.png?raw=true "Carthage Run Script Screenshot")

For Objective-C projects, set the **Embedded Content Contains Swift Code** flag to **Yes** (found under **Build Options** in the **Build Phases** tab).

### Manually Add Subprojects

You can integrate Uber Rides into your project manually without using a dependency manager.

Drag the `UberRides` project into your own and add the resource as an **Embedded Binary**, as well as a **Target Dependency** and **Linked Framework** (under Build Phases) in order to build on the simulator and on a device.

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

First, configure `RidesClient` with your registered Client ID. The end of `application:didFinishLaunchingWithOptions:` in your `AppDelegate` is a good place to do this:

```swift
// Swift
func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    RidesClient.sharedInstance.configureClientID("YOUR_CLIENT_ID")
    return true
}
```

```objective-c
// Objective-C
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[RidesClient sharedInstance] configureClientID:@"YOUR_CLIENT_ID"];
    return YES;
}
```

Import the library into your project, and add a Ride Request Button to your view like you would any other UIView:

```swift
// Swift
import UberRides
let button = RequestButton()
view.addSubview(button)
```

```objective-c
// Objective-C
@import UberRides;
RequestButton *button = [[RequestButton alloc] init];
[view addSubview:button];
```

This will create a request button with default behavior, with the pickup pin set to the user’s current location. The user will need to select a product and input additional information when they are switched over to the Uber application.

### Adding Parameters

We suggest passing additional parameters to make the Uber experience even more seamless for your users. For example, dropoff location parameters can be used to automatically pass the user’s destination information over to the driver:

```swift
// Swift
button.setProductID("abc123-productID")
button.setPickupLocation(latitude: 37.770, longitude: -122.466, nickname: "California Academy of Sciences")
button.setDropoffLocation(latitude: 37.791, longitude: -122.405, nickname: "Pier 39")
```

```objective-c
// Objective-C
[button setProductID:@"abc123-productID"];
[button setPickupLocationWithLatitude:37.770 longitude:-122.466 nickname:@"California Academy of Sciences" address:nil];
[button setDropoffLocationWithLatitude:37.791 longitude:-122.405 nickname:@"Pier 39" address:nil];
```

With all the necessary parameters set, pressing the button will seamlessly prompt a ride request confirmation screen.

### Color Style

The default color has a black background with white text. You can intialize the button to have a white background with black text by passing an additional parameter.

```swift
// Swift
let blackButton = RequestButton()
let whiteButton = RequestButton(.white)
```

```objective-c
// Objective-C
RequestButton *blackButton = [[RequestButton alloc] init];
RequestButton *whiteButton = [[RequestButton alloc] initWithColorStyle:RequestButtonColorStyleWhite];
```

## Example Apps

Example apps can be found in the `examples` folder. To run it, browse to the `examples` directory, run `pod install`, then open `SwiftSDK.xcworkspace` or `ObjcSDK.xcworkspace` in Xcode and run it.

Don’t forget to configure `RidesClient` with your Client ID in your `AppDelegate` file.

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
