# UberSDK

A sample app demonstrating how to use the Uber iOS SDK.

<img src="../../img/uber_sdk.png?raw=true" width=300 alt="Login Button"/>

## Setup
In the UberSDK project's Info.plist, replace the ClientID and RedirectURI with your app's values in the [Uber Developer's Portal](https://developer.uber.com/dashboard/).

## Login
Example usage for the UberAuth login class.

### Auth Type
Specifies the auth grant flow to use for login. Authorization Code is the only option.

### Destination
Sets the auth destination for login. `.inApp` and `.native` are the only options.
If the native Uber app is not installed on the device, `.inApp` is used.

### Exchange Auth Code for Token
Determines if the authorization code should be exchanged locally for an access token

### Always ask for Login
If enabled, the Uber login page will always ask for re-authentication.

### Always ask for Consent
If enabled, the user will always have to agree to linking their account.

### Prefill Values
Allows setting optional values for prefilling user information on the login screen.


## Uber Button
Example usage of the LoginButton convenience UI for login / logout.

## Request a Ride Button
Example usage of the RideRequestButton convenience UI for requesting a ride.
To enable, first log in using either the Login or UberButton section.
