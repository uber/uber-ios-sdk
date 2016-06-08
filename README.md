# Uber Rides iOS SDK (beta)

This [Swift library] (https://developer.apple.com/library/ios/documentation/General/Reference/SwiftStandardLibraryReference/) allows you to integrate Uber into your iOS app.

## Beta

Please keep in mind that this SDK is in a Pre-1.0 release state and is still actively being developed. There may be breaking changes introduced as we work towards stability. Please check the Changelog before updating to a new version.

## Requirements

- iOS 8.0+
- Xcode 7.3+

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

### Carthage

You can integrate Uber Rides into your project using [Carthage](https://github.com/Carthage/Carthage). You can install Carthage (with XCode 7+) via homebrew:

```
brew update
brew install carthage
```
 To install UberRides via Carthage, you need to create a `Cartfile` in your project with the following line:

```
# UberRides 
github "https://github.com/uber/rides-ios-sdk" ~> 0.5
```

Now run

```
carthage update --platform iOS
```
To checkout & build our repo + dependencies. You should now have a `Carthage/Build` folder in your project directory. Open your xcodeproj and go to the **General** settings tab. In the **Linked Frameworks and Libraries** section, drag and drop each framework (in `Carthage/Build/iOS`)

Now Open your application target's **Build Phases** settings tab, click the `+` icon, and select **New Run Script Phase**. Add the following to the script area:

```
/usr/local/bin/carthage copy-frameworks
```

and add the paths to the required frameworks in **Input Files**

```
$(SRCROOT)/Carthage/Build/iOS/UberRides.framework
$(SRCROOT)/Carthage/Build/iOS/ObjectMapper.framework
```

For Objective-C projects, set the **Embedded Content Contains Swift Code** flag in your project to `Yes` (found under **Build Options** in the **Build Settings** tab).

Build your project and everything should be good to go!

### Manually Add Subprojects

You can integrate Uber Rides into your project manually without using a dependency manager.

Drag the `UberRides.xcodeproj` project into your project as a subproject

In your project's Build Target, click on the **General** tab and then under **Embedded Binaries** click the `+` button. Choose the `UberRides.framework` in your project.

Now we need to get our dependencies. All of our dependencies are included as submodules in the `Carthage/Checkouts` folder. 

Once you have the dependencies, drag each xcodeproj into your project (like you did with UberRides)

Click back onto the UberRides subproject, go to the **General** tab and click the `+` button under **Linked Frameworks and Libraries**

Select each of the dependencies you just added.

For Objective-C projects, set the **Embedded Content Contains Swift Code** flag in your project to `Yes` (found under **Build Options** in the **Build Settings** tab).

Now build your project and everything should be good to go!

### Configuring iOS 9.0

If you are compiling on iOS SDK 9.0, you will need to modify your application’s `plist` to handle Apple’s [new security changes](https://developer.apple.com/videos/wwdc/2015/?id=703) to the `canOpenURL` function.

```
<key>LSApplicationQueriesSchemes</key>
<array>                                           
<string>uber</string>
<string>uberauth</string>
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
<key>UberDisplayName</key>
<string>[App Name]</string>
<key>UberCallbackURIs</key>
<array>
    <dict>
        <key>UberCallbackURIType</key>
        <string>General</string>
        <key>URIString</key>
        <string>callback://your_callback_uri</string>
    </dict>
</array>
```

Make sure the value for UberCallbackURI exactly matches one of the Redirect URLs you have set on your developer dashboard. (You can use `localhost` for testing.)

You can also define specific callback URIs for different login types. For example, if you want to use Native login, but also support a fallback to Authorization Code Grant, you can define a callback to your app AND a callback for your server:

```
<key>UberCallbackURIs</key>
<array>
    <dict>
        <key>UberCallbackURIType</key>
        <string>General</string>
        <key>URIString</key>
        <string>callback://your_callback_uri</string>
    </dict>
    <dict>
        <key>UberCallbackURIType</key>
        <string>AuthorizationCode</string>
        <key>URIString</key>
        <string>callback://authorization_code_uri</string>
    </dict>
    <dict>
        <key>UberCallbackURIType</key>
        <string>Native</string>
        <key>URIString</key>
        <string>myApp://native_deeplink_callback</string>
    </dict>    
</array>
```
If you don't specify a callback for a login type, the General entry will be used. **Note:** All of these callbacks need to be registered on your developer dashboard.

Additionally, the SDK provides a static Configuration class to further customize your settings. Inside of `application:didFinishLaunchingWithOptions:` in your `AppDelegate` is a good place to do this:

```swift
// Don’t forget to import UberRides
// Swift
func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // China based apps should specify the region
        Configuration.setRegion(.China)
        // If true, all requests will hit the sandbox, useful for testing
        Configuration.setSandboxEnabled(true)
        // If true, Native login will try and fallback to using Authorization Code Grant login (for privileged scopes). Otherwise will redirect to App store
        Configuration.setFallbackEnabled(false)
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
    // If true, Native login will try and fallback to using Authorization Code Grant login (for privileged scopes). Otherwise will redirect to App store
    [UBSDKConfiguration setFallbackEnabled:NO];
    // Complete other setup
    return YES;
}
```

## Location Services
Getting the user to authorize location services can be done with Apple’s CoreLocation framework. The Uber Rides SDK checks the value of `locationServicesEnabled()` in `CLLocationManager`, which must be true to be able to retrieve the user’s current location.

## SSO (Native login with Uber)
SSO is a way to authorize users using the native Uber application. If your users are already logged in on the Uber app, they won't have to enter a username and password to authorize your app. It also allows you to request privileged scopes without having to setup a backend for Authorization Code Grant. To get started, you need to register your app's **Bundle ID** on the [developer dashboard](https://developer.uber.com/dashboard) under **App Signatures**.

You also need to register a callback URI that can deeplink into your app. Make sure that you add this URL scheme to your app's URL Types. You can do this by copying the following lines into your app's Info.plist:

```
<key>CFBundleURLTypes</key>
	<array>
		<dict>
			<key>CFBundleTypeRole</key>
			<string>Editor</string>
			<key>CFBundleURLSchemes</key>
			<array>
				<string>[Callback URI Scheme]</string>
			</array>
		</dict>
	</array>
```
For example, if my callback was `sampleApp://uberSSO`, `sampleApp` is my [Callback URI Scheme]. I would also add `sampleApp://uberSSO` to my `UberCallbackURIs` as described above.

You also need to modify your application's **App Delegate** to make calls to the **RidesAppDelegate** to handle URLs. 

```swift
// Swift
// Add the following calls to your AppDelegate
import UberRides

func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    // Handle incoming SSO Requests
    RidesAppDelegate.sharedInstance.application(application, didFinishLaunchingWithOptions: launchOptions)
    
    // Other logic
    
    return true
}
    
@available(iOS 9, *)
func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
    
    let handledURL = RidesAppDelegate.sharedInstance.application(app, openURL: url, sourceApplication: options[UIApplicationOpenURLOptionsSourceApplicationKey] as? String, annotation: options[UIApplicationOpenURLOptionsAnnotationKey])
    
    if (!handledURL) {
        // Other URL parsing logic 
    }
    
    return true
}
    
func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
    let handledURL = RidesAppDelegate.sharedInstance.application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    
    if (!handledURL) {
        // Other URL parsing logic
    }
    
    return true
}
```

```objective-c
// Objective-C
// Add the following calls to your AppDelegate
#import <UberRides/UberRides-Swift.h>

// iOS 9+
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options {
    BOOL handledURL = [[UBSDKRidesAppDelegate sharedInstance] application:app openURL:url sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey] annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
    
    if (!handledURL) {
        // Other URL logic
    }
    
    return true;
}

// iOS 8
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    BOOL handledURL = [[UBSDKRidesAppDelegate sharedInstance] application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
    
    if (!handledURL) {
        // Other URL logic
    }
    
    return true;
}
```

## Example Usage
### Quick Integration
#### LoginButton
The `LoginButton` is a simple way to authorize your users. You initialize the button with an array of `RidesScope` and a `LoginManager`. When the user taps the button, the login will be executed. 

You can optionally set a `LoginButtonDelegate` to handle logging in / logging out

```swift
// Swift
let scopes = [.Profile, .Places, .Request]
let loginManager = LoginManager(loginType: .Native)
let loginButton = LoginButton(frame: CGRectZero, scopes: scopes, loginManager: loginManager)
loginButton.presentingViewController = self
loginButton.delegate = self
view.addSubview(loginButton)

// Mark: LoginButtonDelegate
    
public func loginButton(button: LoginButton, didLogoutWithSuccess success: Bool) {
	// success is true if logout succeeded, false otherwise
}
    
public func loginButton(button: LoginButton, didCompleteLoginWithToken accessToken: AccessToken?, error: NSError?) {
    if let _ = accessToken {
        // AccessToken Saved
    } else if let error = error {
        // An error occured
    }
}
```

```objective-c
// Objective-C

NSArray<UBSDKRidesScope *> *scopes = @[UBSDKRidesScope.Profile, UBSDKRidesScope.Places, UBSDKRidesScope.Request];

UBSDKLoginManager *loginManager = [[UBSDKLoginManager alloc] initWithLoginType:UBSDKLoginTypeNative];
    
UBSDKLoginButton *loginButton = [[UBSDKLoginButton alloc] initWithFrame:CGRectZero scopes:scopes loginManager:_loginManager];
loginButton.presentingViewController = self;
[loginButton sizeToFit];
loginButton.delegate = self;

#pragma mark - UBSDKLoginButtonDelegate

- (void)loginButton:(UBSDKLoginButton *)button didLogoutWithSuccess:(BOOL)success {
	// success is true if logout succeeded, false otherwise
}

- (void)loginButton:(UBSDKLoginButton *)button didCompleteLoginWithToken:(UBSDKAccessToken *)accessToken error:(NSError *)error {
    if (accessToken) {
		// UBSDKAccessToken saved
    } else if (error) {
		// An error occured
    }
}
```


#### Ride Request Button
The `RideRequestButton` is a simple way to show price and time estimates for Uber products and can be customized to perform various actions (described later). The button takes in `RideParameters` that can describe product ID, pickup location, and dropoff location. By default, the button shows no information. 

All the button needs to gather this additional information is your server token to be configured in the `Info.plist` as described in the **SDK Configuration** section. To display a time estimate, set the product ID and pickup location. To display a price estimate, you need to additionally set a dropoff location. 

<p align="center">
  <img src="https://github.com/uber/rides-ios-sdk/blob/master/img/button_metadata.png?raw=true" alt="Request Buttons Screenshot"/>
</p>

After setting the `RideParameters` on the button, call the `loadRideInformation()` function to show the metadata. You can also utilize the `RidesClient` to get the cheapest product available at a given pickup location.

```swift
// Swift
let button = RideRequestButton()
let ridesClient = RidesClient()
let pickupLocation = CLLocation(latitude: 37.787654, longitude: -122.402760)
let dropoffLocation = CLLocation(latitude: 37.775200, longitude: -122.417587)
let builder = RideParametersBuilder().setPickupLocation(pickupLocation).setDropoffLocation(dropoffLocation)
ridesClient.fetchCheapestProduct(pickupLocation: pickupLocation, completion: {
    product, response in
    if let productID = product?.productID {
        builder = builder.setProductID(productID)
        button.rideParameters = builder.build()
        button.loadRideInformation()
}
})
```

```objective-c
// Objective-C
UBSDKRideRequestButton *button = [[UBSDKRideRequestButton alloc] init];
UBSDKRidesClient *ridesClient = [[UBSDKRidesClient alloc] init];
CLLocation *pickupLocation = [[CLLocation alloc] initWithLatitude: 37.787654 longitude: -122.402760];
CLLocation *dropoffLocation = [[CLLocation alloc] initWithLatitude: 37.775200 longitude: -122.417587];
__block UBSDKRideParametersBuilder *builder = [[UBSDKRideParametersBuilder alloc] init];
builder = [builder setPickupLocation: pickupLocation];
builder = [builder setDropoffLocation: dropoffLocation];
[ridesClient fetchCheapestProductWithPickupLocation: pickupLocation completion:^(UBSDKUberProduct* _Nullable product, UBSDKResponse* _Nullable response) {
    if (product) {
        builder = [builder setProductID: product.productID];
        button.rideParameters = [builder build];
        [button loadRideInformation];
    }
}];
```

You can also use the `RideRequestButtonDelegate` to be informed of success and failure events during a button refresh.

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
builder.setPickupLocation(pickupLocation).setDropoffLocation(dropoffLocation, nickname: "Somewhere", address: "123 Fake St.")
let rideParameters = builder.build()
```

```objective-c
// Objective-C
UBSDKRideParametersBuilder *builder = [[UBSDKRideParametersBuilder alloc] init];
CLLocation *pickupLocation = [[CLLocation alloc] initWithLatitude:37.787654 longitude:-122.402760];
CLLocation *dropoffLocation = [[CLLocation alloc] initWithLatitude:37.775200 longitude:-122.417587];
// You can chain builder function calls
[[builder setPickupLocation:pickupLocation] setDropoffLocation:dropoffLocation nickname: @"Somewhere" address:@"123 Fake St."];
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

**Note:** If you are using a `RideRequestButton` that deeplinks into the Uber app and you want to specify a dropoff location, you must provide a nickname or formatted address for that location. Otherwise, the pin will not display.


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

### Uber Rides API Endpoints
The SDK exposes all the endpoints available in the [Uber Developers documentation](https://developer.uber.com/docs). Some endpoints can be authenticated with a server token, but for most endpoints, you will require a bearer token. A bearer token can be retrieved via implicit grant, authorization code grant, or SSO. To authorize [privileged scopes](https://developer.uber.com/docs/scopes#section-privileged-scopes), you must use authorization code grant or SSO.

The `RidesClient` is your source to access all the endpoints available in the Uber Rides API. With just your server token, you can get a list of Uber products as well as price and time estimates. 

```swift
// Swift example
let ridesClient = RidesClient()
let pickupLocation = CLLocation(latitude: 37.787654, longitude: -122.402760)
ridesClient.fetchProducts(pickupLocation: pickupLocation, completion:{ products, response in
    if let error = response.error {
        // Handle error
        return
    }
    for product in products {
        // Use product
    }
})
```

```objective-c
// Objective-C example
UBSDKRidesClient *ridesClient = [[UBSDKRidesClient alloc] init];
CLLocation *pickupLocation = [[CLLocation alloc] initWithLatitude: 37.787654 longitude: -122.402760];
[ridesClient fetchProductsWithPickupLocation: pickupLocation completion:^(NSArray<UBSDKUberProduct *> * _Nullable products, UBSDKResponse *response) {
    if (response.error) {
        // Handle error
        return;
    }
    for (UBSDKUberProduct *product in products) {
        // Use product
    }
}];
```

To get access to more informative endpoints, you can use implicit grant to obtain a bearer token. This allows you to get a user's profile, trip history, and places. 

With authorization code grant authorization or SSO, you can obtain a bearer token to be used with any request endpoint, such as requesting a ride, getting a receipt, and accessing payment methods. All the endpoints follow the same pattern as in the examples. Check out the API documentation to see what endpoints are available!

| Auth Method              | Token Type    | Allowed Scopes                           |
| :----------------------- | :-------------| :----------------------------------------|
| None                     | Server        | None (can access products and estimates) |
| Implicit Grant           | Bearer        | General                                  |
| Authorization Code Grant | Bearer        | Privileged and General                   |
| SSO                      | Bearer        | Privileged and General                   |

### Authorization Options
Before you can request any rides, you need to get an `AccessToken`. The Uber Rides SDK provides the `LoginManager` class for this task. The `LoginManager` supports Implicit, Authorization Code, and SSO login types, each is outlined below.

### Implicit Grant Authorization
Implict Grant authorization is fairly straight forward. Simply instantiate an instance of `LoginManager` with a `LoginType` of `.Implicit` and use its login method to present the login screen to the user.

```swift
// Swift
let loginManager = LoginManager(loginType: .Implicit)
loginManager.login(requestedScopes:[.RideWidgets], presentingViewController: self, completion: { accessToken, error in
    // Completion block. If accessToken is non-nil, you’re good to go
    // Otherwise, error.code corresponds to the RidesAuthenticationErrorType that occured
})
```

```objective-c
// Objective-C
UBSDKLoginManager *loginManager = [[UBSDKLoginManager alloc] initWithLoginType:UBSDKLoginTypeImplicit];
[loginManager loginWithRequestedScopes:@[ UBSDKRidesScope.RideWidgets ] presentingViewController: self completion: ^(UBSDKAccessToken * _Nullable accessToken, NSError * _Nullable error) {
        // Completion block. If accessToken is non-nil, you're good to go
        // Otherwise, error.code corresponds to the RidesAuthenticationErrorType that occured
    }];
```

The SDK presents a web view controller where the user logs into their Uber account, or creates an account, and authorizes the requested scopes, retrieving an access token which is automatically saved to the keychain.

### Authorization Code Grant
The `LoginManager` is also capable of doing supporting authorization code grant with a redirect to your backend where you can perform a token exchange. Once a user has logged in and a redirect has been executed, the loginCompletion handler is called. This is where you can poll your backend to retrieve the access token, and save it using the TokenManager.

```swift
// Swift example
let loginManager = LoginManager(loginType = .AuthorizationCode)
let scopes: [RidesScope] = [.Profile, .Request]
loginManager.login(requestedScopes: scopes, presentingViewController: self, completion:{ accessToken, error in
    if let error = error {
        // Handle error
        return
    }

    // Create request to retrieve access token
    let request = NSURLRequest(URL: NSURL(string: "YOUR_URL")!)

    NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler:{ (data, response, error) in
        // Get JSON from response
        let jsonString = String(data: data!, encoding: NSUTF8StringEncoding)!
        let accessToken = AccessTokenFactory.createAccessTokenFromJSONString(jsonString)
        if let token = accessToken {
            TokenManager.saveToken(token)
        }
    })
})
```

```objective-c
// Objective-C example
UBSDKLoginManager *loginManager = [[UBSDKLoginManager alloc] initWithLoginType:UBSDKLoginTypeAuthorizationCode];
NSArray<RidesScope *> *scopes = @[RidesScope.Profile, RidesScope.Request];
[loginManager loginWithRequestedScopes:scopes presentingViewController:self completion:^(UBSDKAccessToken * _Nullable accessToken, NSError *error) {
    if (error) {
        NSLog(@"%@", error.localizedDescription);
        // Handle error
        return;
    }

    // Create request tor retrieve access token
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"YOUR_URL"]];
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        // Get JSON from response
        NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        UBSDKAccessToken *accessToken = [UBSDKAccessTokenFactory createAccessTokenFromJSONString:jsonString];
        [UBSDKTokenManager saveToken:accessToken];
    }] resume];
}];
```

And you're set! Any endpoints in the RidesClient will use the saved access token to authorize your requests.

### Native / SSO Authorization
The easiest form of authorization is using the `.Native` login type. It allows you to request Privileged scopes and, if your user is logged into the Uber app, it doesn't require your user to enter a username and password. It requires the user to have the native Uber application on their device. The `LoginManager` defaults to using the Native login type, so you simply instantiate a `LoginManager` and call `login()` with your requested scopes.

```swift
// Swift
let loginManager = LoginManager()
loginManager.login(requestedScopes:[.Request], presentingViewController: self, completion: { accessToken, error in
    // Completion block. If accessToken is non-nil, you’re good to go
    // Otherwise, error.code corresponds to the RidesAuthenticationErrorType that occured
})
```

```objective-c
// Objective-C
UBSDKLoginManager *loginManager = [[UBSDKLoginManager alloc] init];
[loginManager loginWithRequestedScopes:@[ UBSDKRidesScope.Request ] presentingViewController: self completion: ^(UBSDKAccessToken * _Nullable accessToken, NSError * _Nullable error) {
        // Completion block. If accessToken is non-nil, you're good to go
        // Otherwise, error.code corresponds to the RidesAuthenticationErrorType that occured
    }];
```

**Note:** The `presentingViewController` parameter is optional, but if provided, will attempt to intelligently fallback to another login method. Otherwise, it will redirect the user to the App store to download the Uber app.

**Note:** Using Native login requires some additional configuration of the SDK. See the **Configuration** section for more information.

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

Example apps can be found in the `examples` folder. To run build them, you need to use Carthage. (A quick overview of installing Carthage can be found in the **Getting Started** section.) From inside the `examples/Swift SDK` or `examples/Obj-C SDK` folder, run:

```
carthage update --platform iOS
``` 
This will build the required dependencies. Once you do that, open `Swift SDK.xcodeproj` or `Obj-C SDK.xcodeproj` in Xcode and run it.

Don’t forget to set `UberClientID`, `UberDisplayName`, and `UberCallbackURIs` in your `Info.plist` file.

<p align="center">
  <img src="https://github.com/uber/rides-ios-sdk/blob/master/img/example_app.png?raw=true" alt="Example App Screenshot"/>
</p>

## Getting help

Uber developers actively monitor the [Uber Tag](http://stackoverflow.com/questions/tagged/uber-api) on StackOverflow. If you need help installing or using the library, you can ask a question there. Make sure to tag your question with uber-api and ios!

For full documentation about our API, visit our [Developer Site](https://developer.uber.com/).

## Contributing

We :heart: contributions. Found a bug or looking for a new feature? Open an issue and we'll respond as fast as we can. Or, better yet, implement it yourself and open a pull request! We ask that you include tests to show the bug was fixed or the feature works as expected.

**Note:** All contributors also need to fill out the [Uber Contributor License Agreement](http://t.uber.com/cla) before we can merge in any of your changes.

Please open any pull requests against the corresponding development branch (currently `0.5.x-dev` for bug fixes and `0.6.x-dev` for new features)

## License

The Uber Rides iOS SDK is released under the MIT license. See the LICENSE file for more details.
