# Uber iOS SDK
Integrate Uber into your iOS app.

## Quick Start

```objective-c
#import <UberSDK/UberSDK.h>

// ...

UberAPIClient *uber = [[UberAPIClient alloc] initWithServerToken:@"your_server_token"];

// some location
CLLocationCoordinate2D location = CLLocationCoordinate2DMake(40.7471787,-73.997494);

// get a list of Uber products at the specified location
[client productsWithCoordinate:location completion:^(NSArray *products, NSError *error) {
	// handle response here
}];

```


## Demo

1. Register your test app with Uber at https://developer.uber.com
2. Open the UberSDK-Example project.
3. Navigate to the UBEndpointsViewController.m file.
4. Add your credentials (as obtained in Step 1) to the `init` method.
5. Run the app in the simulator or on the device.


## Adding GPUberView to Your Project

### CocoaPods

TODO


## Usage

### Register You App With Uber

Register your application here: https://developer.uber.com. Once registered, you will have access to the necessary keys and authentication settings to enable your app.

### Import the SDK

```objective-c
#import <UberSDK/UberSDK.h>
```

### Sandbox Mode

By default all requests run in sandbox mode. Disable the sandbox for production apps.

```
[UberAPIClient sandbox:NO];
```


### Authentication

Before you begin, you should determine what level of access your application needs.


#### Server Token

Many applications will only use the Products, Price Estimates, and Time Estimates endpoints. For these, you only need to use the server token to access resources via the API Token Authentication.

```
UberAPIClient *uber = [[UberAPIClient alloc] initWithServerToken:@"your_server_token"];
```

#### OAuth Access Token

If your application will access resources on behalf of an Uber user, such as with the Me and User Activity endpoints, you will need an OAuth access token.

```
UberAPIClient *uber = [[UberAPIClient alloc] initWithAccessToken:@"your_access_token"];
```

#### Getting an OAuth Access Token

You can use any standard method to perform OAuth authentication and retrieve the access token as specified here: https://developer.uber.com/v1/auth/

Otherwise, you can use the included view controller to perform OAuth login and authentication.


```
// 1. Instantiate the view controller.
UBOAuthWebViewController *oauthViewController =
	[[UBOAuthWebViewController alloc] initWithClientId:@"your_client_id"
												secret:@"your_client_secret"
										   redirectUri:@"your_redirect_uri"
										   		scopes:nil];
```
Your **client id**, **client secret**, and **redirect uri** are found/specified in [your app's dashboard](https://developer.uber.com/apps).

The `scopes` argument takes a list of the required scope strings as required by the [specific endpoints](https://developer.uber.com/v1/endpoints/) you're using. Leave `nil` for default scope. You can also use the following pre-defined scopes:
- `UBScopeRequest`
- `UBScopeRequestReceipt`
- `UBScopeProfile`
- `UBScopeHistory`

```
// 2. Assign a delegate, typically self.
oauthViewController.delegate = self;

// 3. Present the view controller in your preferred fashion (typically modaly).
[self presentViewController:[[UINavigationController alloc] initWithRootViewController:oauthViewController]
				   animated:YES
				 completion:nil];
```

If the user successfully logs in and approves your app, the delegate returns an OAuthToken object.
```
- (void)uberOAuthWebViewController:(UBOAuthWebViewController *)viewController didSucceedWithToken:(UBOAuthToken *)token
{
	NSString *accessToken = token.accessToken;
    
    [viewController dismissViewControllerAnimated:YES completion:nil];
}
```

Handle the OAuth error and user cancellation of the login step as needed.
```
- (void)uberOAuthWebViewController:(UBOAuthWebViewController *)viewController didFailWithError:(NSError *)error
{
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)uberOAuthWebViewControllerDidCancel:(UBOAuthWebViewController *)viewController
{
    [viewController dismissViewControllerAnimated:YES completion:nil];
}
```

> Note that it is necessary to dismiss the login view controller in the delegate's callback for all delegate method's.


## Generic Endpoints
These endpoints can be called on a client initialized with either the server token or the OAuth access token.
```
UberAPIClient *client = [[UberAPIClient alloc] initWithServerToken:@"your_server_token"];

// or...

UberAPIClient *client = [[UberAPIClient alloc] initWithAccessToken:@"your_access_token"];
```

### List all active Uber products in the specified region.

```
CLLocationCoordinate2D pickup = CLLocationCoordinate2DMake(40.7471787,-73.997494);

[client productsWithCoordinate:pickup completion:^(NSArray *products, NSError *error) {
	// responds with an array of UBProduct objects
}];
```

### Get a price estimate between the specified start and end locations

```
CLLocationCoordinate2D pickup = CLLocationCoordinate2DMake(40.7471787,-73.997494);
CLLocationCoordinate2D dropoff = CLLocationCoordinate2DMake(40.74844,-73.985664);

[client priceEstimatesWithStartCoordinate:pickup 
                            endCoordinate:dropoff
                               completion:^(NSArray *prices, NSError *error) {

	// responds with an array of UBPriceEstimate objects

}];
```

### Get a pickup time estimate for the specified location.

```
CLLocationCoordinate2D pickup = CLLocationCoordinate2DMake(40.7471787,-73.997494);

[client timeEstimatesWithStartCoordinate:pickup
                              completion:^(NSArray *times, NSError *error) {

	// responds with an array of UBTimeEstimate objects

}];
```

### Get an active promotion for the specified route

```
CLLocationCoordinate2D pickup = CLLocationCoordinate2DMake(40.7471787,-73.997494);
CLLocationCoordinate2D dropoff = CLLocationCoordinate2DMake(40.74844,-73.985664);

[client promotionWithStartCoordinate:pickup
					   endCoordinate:dropoff
					      completion:^(UBPromotion *promotion, NSError *error) {

	// responds with a UBPromotion object

}];
```

## OAuth-only Endpoints

These endpoints must be called on a client initialized with an OAuth access token.
```
UberAPIClient *client = [[UberAPIClient alloc] initWithAccessToken:@"your_access_token"];
```

### Get the user's ride activity

```
NSInteger startOffset = 0;
NSInteger resultLimit = 20;

[client userActivityWithOffset:0
						 limit:5
				    completion:^(NSArray *userActivities,
				    			 NSInteger offset,
				    			 NSInteger limit,
				    			 NSInteger count,
				    			 NSError *error) {

	// responds with an array of UBUserActivity objects

}];
```

### Get the user's profile

```
[client userProfile:^(UBUserProfile *userProfile, NSError *error) {

	// responds with a UBUserProfile object

}];
```

## Requests

These endpoints must be called on a client initialized with an OAuth access token.
```
UberAPIClient *client = [[UberAPIClient alloc] initWithAccessToken:@"your_access_token"];
```

These endpoints are designed to interact with a live Uber vehicle. **Make sure that you are in sandbox mode for development.**

```
[UberAPIClient sandbox:YES];
```

### Making a request

```
NSString *productId = @"some_product_id";
CLLocationCoordinate2D pickup = CLLocationCoordinate2DMake(40.7471787,-73.997494);
CLLocationCoordinate2D dropoff = CLLocationCoordinate2DMake(40.74844,-73.985664);

[self.client requestRideWithProductId:self.product.productId
					  startCoordinate:self.startPin.coordinate
						endCoordinate:self.endPin.coordinate
				  surgeConfirmationId:surgeConfirmation
						   completion:^(UBRide *ride,
										UBSurgeConfirmation *surgeConfirmation,
										NSError *error) {

	// responds with a UBRide object, or an UBSurgeConfirmation object

}];
```

### Surge confirmation

If surge pricing isn't active when you make a request, the preceding call will return an UBRide object. If surge pricing is in effect, you will need confirmation from the user to proceed.

```
// 1. instantiate the surge confirmation view controller and pass-in the UBSurgeConfirmation object 
// returned from the preceding call
UBSurgeConfirmViewController *vc =
	[[UBSurgeConfirmViewController alloc] initWithSurgeConfirmation:surgeConfirmation
                                                      	redirectUri:self.surgeConfirmationUri];
                                                      	
// 2. assign a delegate, typically self
vc.delegate = self;

// 3. present the view controller as desired
[self presentViewController:[[UINavigationController alloc] initWithRootViewController:vc]
				   animated:YES
				 completion:nil];
```

If the user confirms the surge, your delegate will receive the appropriate callback. Repeat the initial request call, this time passing-in the surge confirmation id.

```
- (void)uberSurgeConfirmViewController:(UBSurgeConfirmViewController *)viewController
          didSucceedWithConfirmationId:(NSString *)confirmationId
{
	// make the request call with confirmationId
	
	// dismiss surge confirmation view controller
    [viewController dismissViewControllerAnimated:YES completion:nil];
}
```

Note that the user can also decline surge pricing. In this case simply dismiss the confirmation view controller.
```
- (void)uberSurgeConfirmViewController:(UBSurgeConfirmViewController *)viewController
{
	// dismiss surge confirmation view controller
    [viewController dismissViewControllerAnimated:YES completion:nil];
}
```

### Request details

Once you have a request, you can use its ID to query additional details. These details, (including the current location of the car) will change depending on the trip state.

```
[client rideDetailsWithRequestId:self.request.requestId 
					  completion:^(UBRide *ride, NSError *error) {

	// responds with an UBRide object

}];
```
### Time and price estimate

```
NSString *productId = @"some_product_id";
CLLocationCoordinate2D pickup = CLLocationCoordinate2DMake(40.7471787,-73.997494);
CLLocationCoordinate2D dropoff = CLLocationCoordinate2DMake(40.74844,-73.985664);

[self.client requestEstimateWithProductId:self.product.productId
						  startCoordinate:self.startPin.coordinate
							endCoordinate:self.endPin.coordinate
							   completion:^(UBRideEstimate *estimate, NSError *error) {

	// responds with a UBRideEstimate object

}];
```

### Trip map

```
NSString *requestId = @"your_request_id";

[self.client rideMapWithRequestId:self.ride.requestId 
					   completion:^(NSURL *rideMapURL, NSError *error) {

	// responds with a URL for the map of your trip

}[;
```

### Trip receipt
```
NSString *requestId = @"your_request_id";

[self.client rideReceiptWithRequestId:self.ride.requestId 
						   completion:^(UBReceipt *receipt, NSError *error) {

	// responds with an UBRideReceipt object

}];
```

### Canceling the request
Note, canceling in this case refers to canceling on behalf of the user (rider), not the driver.
```
NSString *requestId = @"your_request_id";

[client cancelRequestWithRequestId:requestId completion:^(NSError *error) {

	// responds with an NSError object if an error has occurred, or nil of the cancel request succeeded

}];
```

## Sandbox Controls

While in sandbox mode, you can control the state of the trip and world.

### Change trip status
You can change the status of the trip as desired (`accepted`, `arriving`, etc.). Available trip states are outlined here: https://developer.uber.com/v1/sandbox/#request

```
NSString *requestId = @"your_request_id";
NSString *newStatus = @"driver_canceled";

[client sandboxChangeRequestWithRequestId:requestId status:newStatus completion:^(NSError *error) {

	// responds with an NSError object if an error has occurred, or nil of the cancel request succeeded

}];
```

### Change the sandbox world's state
You can change the driver availability and surge rate.

```
NSString *productId = @"some_product_id";
BOOL driversAvailable: NO;
double surge = 1.5;

[client sandboxProducts:productId driversAvailable surge:surge completion:^(NSError *error) {

	// responds with an NSError object if an error has occurred, or nil of the cancel request succeeded

}];
```

## Main Thread
Note, all endpoint requests **do not** run on the main thread. If you need to alter UI elements with the response, make sure to do so on the main thread.

```
@property (nonatomic, weak) IBOutlet UILabel *promotionType;

// ...

[client promotionsWithStart:pickup end:dropoff completion:^(UBPromotion *promotion, NSError *error) {
	dispatch_async(dispatch_get_main_queue(), ^{
		self.promotionType.text = promotion.type;
	});
}];
```

## License

TODO

