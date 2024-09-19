## Prerequisites
If you haven't already, follow the [Getting Started](../../README.md#getting-started) steps in the main README.

## Ride Request Button

The `RideRequestButton` is a simple way to show price and time estimates for Uber products and can be customized to perform various actions. The button takes in `RideParameters` that can describe product ID, pickup location, and dropoff location. By default, the button shows no information.

To display a time estimate, set the product ID and pickup location. To display a price estimate, you need to additionally set a dropoff location.

<p align="center">
  <img src="../../img/button_metadata.png?raw=true" alt="Request Buttons Screenshot"/>
</p>

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
import UberRides
import CoreLocation

let builder = RideParametersBuilder()
let pickupLocation = CLLocation(latitude: 37.787654, longitude: -122.402760)
let dropoffLocation = CLLocation(latitude: 37.775200, longitude: -122.417587)
builder.pickupLocation = pickupLocation
builder.dropoffLocation = dropoffLocation
builder.dropoffNickname = "Somewhere"
builder.dropoffAddress = "123 Fake St."
let rideParameters = builder.build()

let button = RideRequestButton(rideParameters: rideParameters)
```

```objective-c
// Objective-C
@import UberRides;
@import CoreLocation;

UBSDKRideParametersBuilder *builder = [[UBSDKRideParametersBuilder alloc] init];
CLLocation *pickupLocation = [[CLLocation alloc] initWithLatitude:37.787654 longitude:-122.402760];
CLLocation *dropoffLocation = [[CLLocation alloc] initWithLatitude:37.775200 longitude:-122.417587];
[builder setPickupLocation:pickupLocation];
[builder setDropoffLocation:dropoffLocation];
[builder setDropoffAddress:@"123 Fake St."];
[builder setDropoffNickname:@"Somewhere"];
UBSDKRideParameters *rideParameters = [builder build];

UBSDKRideRequestButton *button = [[UBSDKRideRequestButton alloc] initWithRideParameters:rideParameters];
```

We suggest passing additional parameters to make the Uber experience even more seamless for your users. For example, dropoff location parameters can be used to automatically pass the user’s destination information over to the driver. With all the necessary parameters set, pressing the button will seamlessly prompt a ride request confirmation screen.

**Note:** If you are using a `RideRequestButton` that deeplinks into the Uber app and you want to specify a dropoff location, you must provide a nickname or formatted address for that location. Otherwise, the pin will not display.

You can also use the `RideRequestButtonDelegate` to be informed of success and failure events during a button refresh.

## Ride Request Deeplink

If you don't want to use the Uber-provided button, you can also manually initiate a deeplink in a similar fashion as above:

```swift
// Swift
import UberRides
import CoreLocation

let builder = RideParametersBuilder()
// ...
let rideParameters = builder.build()

let deeplink = RequestDeeplink(rideParameters: rideParameters)
deeplink.execute()
```

```objective-c
// Objective-C
@import UberRides;
@import CoreLocation;

UBSDKRideParametersBuilder *builder = [[UBSDKRideParametersBuilder alloc] init];
// ...
UBSDKRideParameters *rideParameters = [builder build];

UBSDKRequestDeeplink *deeplink = [[UBSDKRequestDeeplink alloc] initWithRideParameters:rideParameters];
[deeplink executeWithCompletion:nil];
```

With the Ride Request deeplink, you can specify a fallback for users that don't have the Uber app installed. With a fallback, they'll get redirected to either the mobile web version of Uber, or the App Store. To do so, simply add the `fallbackType` parameter:

```swift
// Swift
let deeplink = RequestDeeplink(rideParameters: rideParameters, fallbackType: .mobileWeb) // Or .appStore

// Objective-C
UBSDKRequestDeeplink *requestDeeplink = [[UBSDKRequestDeeplink alloc] initWithRideParameters:rideParameters
                                          fallbackType:UBSDKDeeplinkFallbackTypeMobileWeb];
```

### Uber Rides API Endpoints
The SDK exposes all the endpoints available in the [Uber Developers documentation](https://developer.uber.com/docs). Some endpoints can be authenticated with a server token, but for most endpoints, you will require a bearer token. A bearer token can be retrieved via implicit grant, authorization code grant, or SSO. To authorize [privileged scopes](https://developer.uber.com/docs/scopes#section-privileged-scopes), you must use authorization code grant or SSO.

Read the full API documentation at [CocoaDocs](http://cocoadocs.org/docsets/UberRides/0.14.0/)

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
