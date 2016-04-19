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

For Objective-C projects, set the **Embedded Content Contains Swift Code** flag in your project to **Yes** (found under **Build Options** in the **Build Settings** tab).

### Manually Add Subprojects

You can integrate Uber Rides into your project manually without using a dependency manager.

Drag the `UberRides.xcodeproj` project into your project as a subproject

In your project's Build Target, click on the **General** tab and then under **Embedded Binaries** click the `+` button. Choose the `UberRides.framework` in your project.

Now click on the `UberRides.xcodeproj` sub project and open the **General** tab. Under **Linked Frameworks and Libraries** delete the `Pods.framework` entry

Now click on **Build Phase** (still in the UberRides subproject) and delete the **Check Pods Manifest.lock** & **Copy Pods Resources** script phases

Now we need to get our dependencies. Clone the ObjectMapper dependency [found here](https://github.com/Hearst-DD/ObjectMapper) (we use version 1.1.5)

Once you have that, also drag the `ObjectMapper.xcodeproj` into your project

Click back onto the UberRides subproject, go to the **General** tab and click the `+` button under **Linked Frameworks and Libraries**

Choose the ObjectMapper iOS framework

Now build your project and everything should be good to go

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

## SDK Configuration
In order for the SDK to function correctly, you need to add some information about your app. Locate the **Info.plist** file for your application. Usually found in the **Supporting Files** folder. Right-click this file and select **Open As > Source Code**

Add the following code snippet, replacing the placeholders with your app’s information from the developer dashboard.

```
<key>UberClientID</key>
<string>[ClientID]</string>
<key>UberCallbackURI</key>
<string>[redirect URL]</string>
```

Additionally, the SDK provides a static Configuration class to further customize your settings. Inside of `application:didFinishLaunchingWithOptions:` in your `AppDelegate` is a good place to do this:

```swift
// Don’t forget to import UberRides
// Swift
func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // China based apps should specify the region
        Configuration.setRegion(.China)
        // If true, all requests will hit the sandbox, useful for testing
        Configuration.setSandboxEnabled(true)
        // Complete other setup
        return true
    }
```

```objective-c
// Objective-C
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // China based apps should specify the region
    [UBSDKConfiguration setRegion:RegionChina];
    // If true, all requests will hit the sandbox, useful for testing
    [UBSDKConfiguration setSandboxEnabled:YES];
    // Complete other setup
    return YES;
}
```

## Location Services
Getting the user to authorize location services can be done with Apple’s CoreLocation framework. The Uber Rides SDK checks the value of `locationServicesEnabled()` in `CLLocationManager`, which must be true to be able to retrieve the user’s current location.

## Example Usage
### Quick Integration
#### Ride Request Widget

The Uber Rides SDK provides a simple way to add the Ride Request Widget in only a few lines of code via the `RideRequestButton`. You simply need to provide a `RideRequesting` object and an optional `RideParameters` object.

```swift
// Swift
// Pass in a UIViewController to modally present the Ride Request Widget over
let behavior = RideRequestViewRequestingBehavior(presentingViewController: self)
// Optional, defaults to using the user’s current location for pickup
let location = CLLocation(latitude: 37.787654, longitude: -122.402760)
let parameters = RideParametersBuilder().setPickupLocation(location).build()
let button = RideRequestButton(rideParameters: parameters, requestingBehavior: behavior)
self.view.addSubview(button)
```

```objective-c
// Objective-C
// Pass in a UIViewController to modally present the Ride Request Widget over
id<UBSDKRideRequesting> behavior = [[UBSDKRideRequestViewRequestingBehavior alloc] initWithPresentingViewController: self];
// Optional, defaults to using the user’s current location for pickup
CLLocation *location = [[CLLocation alloc] initWithLatitude: 37.787654 longitude: -122.402760];
UBSDKRideParametersBuilder *builder = [[UBSDKRideParametersBuilder alloc] init];
[builder setPickupLocation:location];
UBSDKRideParameters *parameters = [builder build];
UBSDKRideRequestButton *button = [[UBSDKRideRequestButton alloc] initWithRideParameters: parameters requestingBehavior: behavior];
[self.view addSubview:button];
```

That’s it! When a user taps the button, a **RideRequestViewController** will be modally presented, containing a **RideRequestView** prefilled with the information provided from the **RideParameters** object. If they aren’t signed in, the modal will display a login page and automatically continue to the Ride Request Widget once they sign in. 

Basic error handling is provided by default, but can be overwritten by specifying a **RideRequestViewControllerDelegate**.

```swift
// Swift
extension your_class : RideRequestViewControllerDelegate {
   func rideRequestViewController(rideRequestViewController: RideRequestViewController, didReceiveError error: NSError) {
        let errorType = RideRequestViewErrorType(rawValue: error.code) ?? .Unknown
        // Handle error here
        switch errorType {
        case .AccessTokenMissing:
            // No AccessToken saved
        case .AccessTokenExpired:
            // AccessToken expired / invalid
        case .NetworkError:
            // A network connectivity error
        case .NotSupported:
            // The attempted operation is not supported on the current device
        case .Unknown:
            // Other error
        }
    }
}

// Use your_class as the delegate
let behavior = RideRequestViewRequestingBehavior(presentingViewController: self)
let delegate = your_class()
behavior.modalRideRequestViewController.rideRequestViewController.delegate = delegate
// Create the button same as before
let button = RideRequestButton(rideParameters: parameters, requestingBehavior: behavior)
```

```objective-c
// Objective-C
// Need to implement the UBSDKRideRequestViewControllerDelegate
@interface your_class () <UBSDKRideRequestViewControllerDelegate>

@end

// Implement the delegate methods
- (void)rideRequestViewController:(RideRequestViewController *)rideRequestViewController didReceiveError:(NSError *)error {
    // Handle error here
    RideRequestViewErrorType errorType = (RideRequestViewErrorType)error.code;
    
    switch (errorType) {
        case RideRequestViewErrorTypeAccessTokenExpired:
            // No AccessToken saved
            break;
        case RideRequestViewErrorTypeAccessTokenMissing:
            // AccessToken expired / invalid
            break;
        case RideRequestViewErrorTypeNetworkError:
            // A network connectivity error
            break;
        case RideRequestViewErrorTypeUnknown:
            // Other error
            break;
        default:
            break;
    }
}

// Assign the delegate when you initialize your UBSDKRideRequestViewRequestingBehavior
UBSDKRideRequestViewRequestingBehavior *requestBehavior = [[UBSDKRideRequestViewRequestingBehavior alloc] initWithPresentingViewController:self];
// Subscribe as the delegete
requestBehavior.modalRideRequestViewController.delegate = self;
// Create the button same as before
UBSDKRideRequestButton *button = [[UBSDKRideRequestButton alloc] initWithRideParameters: parameters requestingBehavior: requestBehavior];
[self.view addSubview:button];
```

#### Deep linking

Import the library into your project, and add a Ride Request Button to your view like you would any other UIView:

```swift
// Swift
import UberRides

let button = RideRequestButton()
view.addSubview(button)
```

```objective-c
// Objective-C
@import UberRides;

UBSDKRideRequestButton *button = [[UBSDKRideRequestButton alloc] init];
[view addSubview:button];
```

This will create a request button with default behavior, with the pickup pin set to the user’s current location. The user will need to select a product and input additional information when they are switched over to the Uber application.

### Adding Parameters with RideParameters

The SDK provides an simple object for defining your ride requests. The `RideParameters` object lets you specify pickup location, dropoff location, product ID, and more. Creating `RideParameters` is easy using the `RideParametersBuilder` object.

```swift
// Swift
let builder = RideParametersBuilder()
let pickupLocation = CLLocation(latitude: 37.787654, longitude: -122.402760)
let dropoffLocation = CLLocation(latitude: 37.775200, longitude: -122.417587)
// You can chain builder function calls
builder.setPickupLocation(pickupLocation).setDropoffLocation(dropoffLocation)
let rideParameters = builder.build()
```

```objective-c
// Objective-C
UBSDKRideParametersBuilder *builder = [[UBSDKRideParametersBuilder alloc] init];
CLLocation *pickupLocation = [[CLLocation alloc] initWithLatitude:37.787654 longitude:-122.402760];
CLLocation *dropoffLocation = [[CLLocation alloc] initWithLatitude:37.775200 longitude:-122.417587];
// You can chain builder function calls
[[builder setPickupLocation:pickupLocation] setDropoffLocation:dropoffLocation];
UBSDKRideParameters *rideParameters = [builder build];
```

You can also have the SDK determine the user’s current location (you must handle getting location permission beforehand, however)

```swift
// Swift
// If no pickup location is specified, the default is to use current location
let parameters = RideParametersBuilder().build()
// You can also explicitly the parameters to use current location
let builder = RideParametersBuilder()
builder.setPickupToCurrentLocation()
let parameters = builder.build()  // Both 'parameters' variables are equivalent
```

```objective-c
// Objective-C
// If no pickup location is specified, the default is to use current location
UBSDKRideParameters *parameters = [[[UBSDKRideParametersBuilder alloc] init] build];
// You can also explicitly the parameters to use current location
UBSDKRideParametersBuilder *builder = [[UBSDKRideParametersBuilder alloc] init];
[builder setPickupToCurrentLocation];
UBSDKRideParameters *parameters = [builder build]; // Both 'parameters' variables are equivalent
```

We suggest passing additional parameters to make the Uber experience even more seamless for your users. For example, dropoff location parameters can be used to automatically pass the user’s destination information over to the driver. With all the necessary parameters set, pressing the button will seamlessly prompt a ride request confirmation screen.

### RideRequestButton Color Style

The default color has a black background with white text. You can update the button to have a white background with black text by setting the color style

```swift
// Swift
let button = RideRequestButton() // Black Background, White Text
button.colorStyle = .White // White Background, Black Text
```

```objective-c
// Objective-C
UBSDKRideRequestButton *button = [[UBSDKRideRequestButton alloc] init]; // Black Background, White Text
[button setColorStyle:RequestButtonColorStyleWhite]; // White Background, Black Text
```

## Custom Integration
If you want to provide a more custom experience in your app, there are a few classes to familiarize yourself with. Read the sections below and you’ll be requesting rides in no time!

### Implicit Grant Authorization
Before you can request any rides, you need to get an `AccessToken`. The Uber Rides SDK provides the `LoginManager` class for this task. Simply instantiate an instance use its login method to present the login screen to the user.

```swift
// Swift
let loginManager = LoginManager()
loginManager.login(requestedScopes:[.RideWidgets], presentingViewController: self, completion: { accessToken, error in
    // Completion block. If accessToken is non-nil, you’re good to go
    // Otherwise, error.code corresponds to the RidesAuthenticationErrorType that occured
})
```

```objective-c
// Objective-C
UBSDKLoginManager *loginManager = [[UBSDKLoginManager alloc] init];
[loginManager loginWithRequestedScopes:@[ UBSDKRidesScope.RideWidgets ] presentingViewController: self completion: ^(UBSDKAccessToken * _Nullable accessToken, NSError * _Nullable error) {
        // Completion block. If accessToken is non-nil, you're good to go
        // Otherwise, error.code corresponds to the RidesAuthenticationErrorType that occured
    }];
```

The only required scope for the Ride Request Widget is the `RideWidgets` scope, but you can pass in any other scopes that you’d like access to.

The SDK presents a web view controller where the user logs into their Uber account, or creates an account, and authorizes the requested scopes, retrieving an access token which is automatically saved to the keychain. Once the SDK has the access token, the embedded ride request control is ready to be used!

### Custom Authorization / TokenManager
If your app allows users to authorize via your own customized logic, you will need to create an `AccessToken` manually and save it in the keychain using the `TokenManager`.

```swift
// Swift
let accessTokenString = "access_token_string"
let token = AccessToken(tokenString: accessTokenString)
if TokenManager.saveToken(token) {
    // Success
} else {
    // Unable to save
}
```

```objective-c
// Objective-C
NSString *accessTokenString = @"access_token_string";
UBSDKAccessToken *token = [[UBSDKAccessToken alloc] initWithTokenString: accessTokenString];
if ([UBSDKTokenManager saveToken: token]) {
	// Success
} else {
	// Unable to save
}
```

The `TokenManager` can also be used to fetch and delete `AccessToken`s

```swift
// Swift
TokenManger.fetchToken()
TokenManager.deleteToken()
```

```objective-c
// Objective-C
[UBSDKTokenManager fetchToken];
[UBSDKTokenManager deleteToken];
```

### RideRequestView
The `RideRequestView` is like any other view you’d add to your app. Create a new instance using a `RideParameters` object and add it to your app wherever you like. 

```swift
// Swift
// Example of setting up the RideRequestView
let location = CLLocation(latitude: 37.787654, longitude: -122.402760)
let parameters = RideParametersBuilder().setPickupLocation(location).build()
let rideRequestView = RideRequestView(rideParameters: parameters, frame: self.view.bounds)
self.view.addSubview(rideRequestView)
```

```objective-c
// Objective-C
// Example of setting up the UBSDKRideRequestView
CLLocation *location = [[CLLocation alloc] initWithLatitude: 37.787654 longitude: -122.402760];
UBSDKRideParametersBuilder *builder = [[UBSDKRideParametersBuilder alloc] init];
UBSDKRideParameters *parameters = [[builder setPickupLocation:location] build];
UBSDKRideRequestView *rideRequestView = [[UBSDKRideRequestView alloc] initWithRideParameters:parameters frame:self.view.bounds];
[self.view addSubview:rideRequestView];
```

That’s it! When you’re ready to show the control, call the load() function. This function will also poll for the user’s current location, if set in your `RideParameters`, before loading the widget. 

You can also optionally specify a `RideRequestViewDelegate` to handle errors loading the widget.

```swift
// Swift
extension your_class : RideRequestViewDelegate {
   func rideRequestView(rideRequestView: RideRequestView, didReceiveError error: NSError) {
        let errorType = RideRequestViewErrorType(rawValue: error.code) ?? .Unknown
        // Handle error here
        switch errorType {
        case .AccessTokenMissing:
            // No AccessToken saved
        case .AccessTokenExpired:
            // AccessToken expired / invalid
        case .NetworkError:
            // A network connectivity error
        case .NotSupported:
            // The attempted operation is not supported on the current device
        case .Unknown:
            // Other error
        }
    }
}
```
```objective-c
// Objective-C
// Delegate methods
- (void)rideRequestView:(UBSDKRideRequestView *)rideRequestView didReceiveError:(NSError *)error {
    // Handle error here
    RideRequestViewErrorType errorType = (RideRequestViewErrorType)error.code;
    
    switch (errorType) {
        case RideRequestViewErrorTypeAccessTokenExpired:
            // No AccessToken saved
            break;
        case RideRequestViewErrorTypeAccessTokenMissing:
            // AccessToken expired / invalid
            break;
        case RideRequestViewErrorTypeNetworkError:
        	  // A network connectivity error
        	  break;
        case RideRequestViewErrorTypeUnknown:
            // Other error
            break;
        default:
            break;
    }
}
```

### RideRequestViewController
A `RideRequestViewController` is simply a `UIViewController` that contains a fullscreen `RideRequestView`. It also handles logging in non-authenticated users for you. Create a new instance with your desired `RideParameters` and `LoginManager` (used to log in, if necessary). 

```swift
// Swift
// Setting up a RideRequestViewController
let parameters = RideParametersBuilder().build()
let loginManager = LoginManager()
let rideRequestViewController = RideRequestViewController(rideParameters: parameters, loginManager: loginManager)
```
```objective-c
// Objective-C
// Setting up a RideRequestViewController
UBSDKRideParameters *parameters = [[[UBSDKRideParametersBuilder alloc] init] build];
UBSDKLoginManager *loginManager = [[UBSDKLoginManager alloc] init];
UBSDKRideRequestViewController *rideRequestViewController = [[UBSDKRideRequestViewController alloc] initWithRideParameters:parameters loginManager:loginManager];
```

You can also optionally specify a RideRequestViewControllerDelegate to handle potential errors passed from the wrapped RideRequestView

```swift
// Swift
extension your_class : RideRequestViewControllerDelegate {
    func rideRequestViewController(rideRequestViewController: RideRequestViewController, didReceiveError error: NSError) {
        let errorType = RideRequestViewErrorType(rawValue: error.code) ?? .Unknown
        // Handle error here
        switch errorType {
        case .AccessTokenMissing:
            // No AccessToken saved
        case .AccessTokenExpired:
            // AccessToken expired / invalid
        case .NetworkError:
            // A network connectivity error
        case .NotSupported:
            // The attempted operation is not supported on the current device
        case .Unknown:
            // Other error
        }
    }
}
```
```objective-c
// Objective-C
// Implement the delegate methods
- (void)rideRequestViewController:(UBSDKRideRequestViewController *)rideRequestViewController didReceiveError:(NSError *)error {
    // Handle error here
    RideRequestViewErrorType errorType = (RideRequestViewErrorType)error.code;
    
    switch (errorType) {
        case RideRequestViewErrorTypeAccessTokenExpired:
            // No AccessToken saved
            break;
        case RideRequestViewErrorTypeAccessTokenMissing:
            // AccessToken expired / invalid
            break;
        case RideRequestViewErrorTypeNetworkError:
        	  // A network connectivity error
        	  break;
        case RideRequestViewErrorTypeUnknown:
            // Other error
            break;
        default:
            break;
    }
}
```

## Example Apps

Example apps can be found in the `examples` folder. To run it, browse to the `examples` directory, run `pod install`, then open `SwiftSDK.xcworkspace` or `ObjcSDK.xcworkspace` in Xcode and run it.

Don’t forget to set `UberClientID` with your Client ID in your `Info.plist` file.

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
