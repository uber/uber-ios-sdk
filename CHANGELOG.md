# Change Log

## [0.14.0] 2023-04-18

* [Pull #278](https://github.com/uber/rides-ios-sdk/pull/278) Implementing PAR
* [Pull #277](https://github.com/uber/rides-ios-sdk/pull/277) Bump deployment target to iOS 11

## [0.13.0] 2019-11-24

* [Pull #264](https://github.com/uber/rides-ios-sdk/pull/264) iOS 13: Don't check for source application

## [0.12.0] 2019-04-10

* [Pull #257](https://github.com/uber/rides-ios-sdk/pull/257) Added token_type property support to AccessToken model

## [0.11.0] 2018-10-22

0.11 updates the Uber Rides SDK for Xcode 10/Swift 4.2 compatibility. ([Pull #245](https://github.com/uber/rides-ios-sdk/pull/245), thanks @rmuhamedgaliev!)

### Changes
* [Pull #248](https://github.com/uber/rides-ios-sdk/pull/248) You can now use custom string scopes, with the initializer `UberScope(scopeString:)`
* [Pull #242 & #243](https://github.com/uber/rides-ios-sdk/pull/242) add support for authenticating with Uber Eats

## [0.10.0] 2018-04-27

0.10 updates the Uber Rides SDK for Xcode 9.3/Swift 4.1 compatibility.

### Changes

* [Pull #228](https://github.com/uber/rides-ios-sdk/pull/228) Resolves SSO crash on Xcode 9.30
* [Pull #233](https://github.com/uber/rides-ios-sdk/pull/233) Ensures Login button UI updates happen on the Main Queue

## [0.9.0] 2018-02-13

### Changes

* [Pull #213](https://github.com/uber/rides-ios-sdk/pull/213) All model properties are now Optionals. 
  * In Objective-C, `Double`, `Int`, and `Bool` are represented by NSNumber `boolValue`, `intValue`, and `doubleValue`. The `UBSDKDistanceUnavailable`, `UBSDKEstimateUnavailable`, and `UBSDKBearingUnavailable` constants are now removed. 
* [Pull #217](https://github.com/uber/rides-ios-sdk/pull/217) Add fallback to m.uber.com for Ride Request Deeplinks -- you can now have the Ride Request Deeplink fallback to Uber's web experience instead of using the App Store. 

### Deprecated

 * The Ride Request Widget is now deprecated. New apps will not be able to add the Ride Request Widget, and existing apps have until 05/31/2018 to migrate. See the [Uber API Changelog](https://developer.uber.com/docs/riders/change-log) for more details. 

## [0.8.2] 2018-02-06

### Changes

* [Pull #223](https://github.com/uber/rides-ios-sdk/pull/223) Uses Apple's new openURL API for iOS 10+ devices. 

## [0.8.1] 2018-01-31

### Fixes

* [Pull #222](https://github.com/uber/rides-ios-sdk/pull/222) Fixes [Issue #90](https://github.com/uber/rides-ios-sdk/issues/90), where a user would get a "User cancelled the login error" erroneously. 

## [0.8.0] 2017-11-28

0.8 separates the Uber Rides SDK into two modules, `UberRides` and `UberCore`. It also contains a number of authentication-related changes to simplify the Login with Uber flows. 

When migrating to 0.8, you may need to add `import UberCore` to files previously importing just `UberRides`, and rename usage of some classes below. 

### Changes

* `LoginManager` now uses `SFAuthenticationSession`, `SFSafariViewController`, or external Safari for web-based OAuth flows.
* `Deeplinking` protocol simplified. Public properties from the previous protocol is now available under the `.url` property. 
* `UberAuthenticating` protocol simplified. 
* `AccessToken` adds two new initializers intended to make custom OAuth flows easier. Fixes [Issue #187](https://github.com/uber/rides-ios-sdk/issues/187)

### Moved to UberCore

* `Configuration`
* `TokenManager`
* `RidesAppDelegate` -> `UberAppDelegate`
* `UberAPI` -> `APIEndpoint`
* `RidesError` -> `UberError`
* `RidesScope` -> `UberScope`
* `Deeplinking`, `BaseDeeplink`, `AppStoreDeeplink`, `AuthenticationDeeplink`
* `UberAuthenticating`, `BaseAuthenticator`, `AuthorizationCodeGrantAuthenticator`, `ImplicitGrantAuthenticator`,  `NativeAuthenticator`
* `UberButton`
* `UBSDKConstants`

### Removed

* `LoginView` - initiate the login process via `LoginManager` instead.
* `LoginViewAuthenticator` - initiate the login process via `LoginManager` instead.
* `OAuthViewController` - initiate the login process via `LoginManager` instead.

## [0.7.0] 2017-09-15

0.7 makes the Uber Rides iOS SDK compatible with iOS 11 and Swift 4.

### Added
* [Pull #138](https://github.com/uber/rides-ios-sdk/pull/138) and [Pull #168](https://github.com/uber/rides-ios-sdk/pull/168) Brazil localization
* [Pull #143](https://github.com/uber/rides-ios-sdk/pull/143) Russian localization
* Moved to GitHub-first development.
* Support for Travis CI

### Fixed
* [Pull #178](https://github.com/uber/rides-ios-sdk/pull/178) Migrated the SDK to Swift 4
* [Pull #176](https://github.com/uber/rides-ios-sdk/pull/176) and [Pull #177](https://github.com/uber/rides-ios-sdk/pull/177) Changed APIs to be more idiomatic with Swift
* [Pull #180](https://github.com/uber/rides-ios-sdk/pull/180) Use the api.uber.com V1.2 endpoints
* [Pull #184](https://github.com/uber/rides-ios-sdk/pull/184) Updated the Sample Apps to use the current SDK

### Removed
* [Pull #175](https://github.com/uber/rides-ios-sdk/pull/175) China support is now removed
* `RidesClient.fetchCheapestProduct` is removed since the Ride Request API no longer supports it with upfront fares.
* [Pull #179](https://github.com/uber/rides-ios-sdk/pull/179) `UberRides` no longer depends on `ObjectMapper`

## [0.6.0] 2016-11-22

### Added
Added Swift 2.3 support

## [0.5.3] 2016-11-18

This will be the final release using Swift 2.2

### Fixed

- [Issue #51](https://github.com/uber/rides-ios-sdk/issues/51) Added Information about Server Token in README
- [Issue #58](https://github.com/uber/rides-ios-sdk/issues/58) Updated README examples to correctly use pickup & dropoff
- [Issue #76](https://github.com/uber/rides-ios-sdk/issues/76) Update Ride Request Button Delegate to always fire. The RideRequestButtonDelegate will now always fire `didLoadRideInformation` once information has been loaded. Including if it encounters an error. Any errors that are encountered will still fire `didReceiveError`. `didReceiveError` will always be called before `didLoadRideInformation`
- [Issue #86](https://github.com/uber/rides-ios-sdk/issues/86) via [Pull #114](https://github.com/uber/rides-ios-sdk/pull/114) Fix RideScope not mapping for all cases
- [Issue #94](https://github.com/uber/rides-ios-sdk/issues/94) Make ride status available in Objective-C
- [Issue #127](https://github.com/uber/rides-ios-sdk/issues/127) Shared Credentials across iOS app and extension

- [Pull #105](https://github.com/uber/rides-ios-sdk/pull/105) Fixing typos
- [Pull #72](https://github.com/uber/rides-ios-sdk/pull/72) Updates to make README more clear
- [Pull #73](https://github.com/uber/rides-ios-sdk/pull/73) Updates to README about info.plist
- [Pull #65](https://github.com/uber/rides-ios-sdk/pull/65) Example of how to run samples without Carthage

## [0.5.2] 2016-08-2
### Added
The Ride Request Widget now attempts to refresh expired access tokens automatically. If you are using the RideRequestViewController, the SDK will attempt to hit the Refresh endpoint with your current Access Token's Refresh Token. If that fails, the user will be redirected to the appropriate login


### Fixed

- [Issue #64](https://github.com/uber/rides-ios-sdk/issues/64) Refresh Endpoint returning error
- [Issue #57](https://github.com/uber/rides-ios-sdk/issues/57) Client login errors from expired access tokens. 
- [Issue #52](https://github.com/uber/rides-ios-sdk/issues/57) Carthage setup incorrectly copying frameworks

## [0.5.1] 2016-06-14
### Fixed

- [Issue #47](https://github.com/uber/rides-ios-sdk/issues/47) SSO fails for correctly configured China apps. SDK now sends the correct Region string for SSO 

## [0.5.0] 2016-06-2
### Added

#### SSO (Native login with Uber) 
Introducing **SSO**. Allows a user to sign in & authorize your application via the native Uber app. Users no longer have to remember their username & password as long as they are signed into the Uber app.

- Added `LoginType.Native`
- Added `NativeLoginAuthenticator` 
- Added `LoginButton`

#### LoginButton
Added a built in button to make login easier. Uses a `LoginManager` to initiate the login process when the user taps the button. Reflects the logged in / logged out state of the user

#### Support all REST API Endpoints
Updated `RidesClient` to support all of the REST API endpoints. See https://developer.uber.com/docs/api-overview for a complete overview of the endpoints

#### UberAuthenticating Classes
Added Authenticating classes to handle the possible login types

- ImplicitGrantAuthenticator
- AuthorizationCodeGrantAuthenticator
- NativeAuthenticator

These classes should be created with your requested scopes (and potentially other information) and will handle making the correct login call for you. LoginView and LoginManager have been updated to use these new classes

#### Deeplinks

All deeplink objects now subclass the `BaseDeeplink` which encapsulates shared logic for executing a deeplink.

Added new `Deeplinking` objects, `AuthenticationDeeplink` which is used for SSO, and `AppStoreDeeplink` which is used to fallback to the Uber App on the App Store


### Changed

#### Swift 2.2
Updated to using Swift 2.2. XCode 7.3+ is now required

#### Info.plist

There has been an update in how you define your callback URIs in your Info.plist. We now support callbackURIs for different login types. Anything that is not defined will use the `General` type (if you still use the old `UberCallbackURI` key, that will be treated as `General`)

We have also added `UberDisplayName`. This should contain the name of your application. See an example of the new format below

```
	<key>UberClientID</key>
	<string>YOUR_CLIENT_ID</string>
	<key>UberDisplayName</key>
	<string>YOUR_APP_NAME</string>
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
			<string>callback://optional_authorization_code_uri</string>
		</dict>
	</array>
```

You also need to add a new Application Query Scheme on iOS 9+ in order to use SSO

```
	<key>LSApplicationQueriesSchemes</key>
	<array>
		<string>uberauth</string>
		<string>uber</string>
	</array>
```

#### RideRequestButton
The RideRequestButton has been updated to show information about your Uber ride. Requires setting a product ID in your RideParameters and optionally a dropoff address. 

- If only a productID is set, the button will update with a time estimate of how far away a car is
- If dropoff address & productID are set, the button will show a time estimate and a price estimate of the trip

#### Ride Request Widget Button
The Ride Request Widget Button now defaults to using the `.Native` LoginType instead of the previous `.Implicit`. If Native login is unavailable, it will automatically fallback to Implicit

### Breaking

#### LoginBehavior -> LoginType

`LoginBehavior` has been removed, replaced by `LoginType`. Available login types:

- .Implicit
- .AuthorizationCode
- .Native

#### LoginManager
`LoginManager` now takes a `LoginType` instead of a `LoginBehavior`

#### LoginView
`LoginView` is now initialized using the new UberAuthenticating classes rather than an array of `RidesScope`

#### RidesClient

Renamed `getAccessToken()` to `fetchAccessToken()`

### Fixed
- [Issue #29](https://github.com/uber/rides-ios-sdk/issues/29) Carthage Compatible. Updated the SDK to work with Carthage
- [Issue #25](https://github.com/uber/rides-ios-sdk/issues/25) AllTrips scope missing. With the addition of Authorization Code Grant & Native it is now possible to request privileged scopes
- [Issue #17](https://github.com/uber/rides-ios-sdk/issues/17) Warnings with Xcode 7.3. Selector syntax has been updated for Swift 2.2
- [Issue #1](https://github.com/uber/rides-ios-sdk/issues/1) Unclear documentation. Updated README to be more clear

## [0.4.2] 2016-04-19

### Changed

Correctly updated Change Log

## [0.4.1] 2016-04-19
### Added

`NotSupported` RideRequestViewErrorType, which occurs when an operation is not supported by the current device (currently fired if you attempt to open an `sms` or `tel` link on the simulator

### Fixed

- [Issue #22](https://github.com/uber/rides-ios-sdk/issues/22) Attempting to Call / Text driver resulted in Ride Request Widget Closing

## [0.4.0] 2016-04-11
### Added

#### Configuration

Handles SDK Configuration, including `ClientID` and `RedirectURI`. Values are pulled from your app's `Info.plist`

#### LoginManager / Implicit Grant flow
Added implicit grant (i.e. token) login authorization flow for non-privileged scopes (profile, history, places, ride_widgets)

- Added `OAuthViewController` & `LoginView`
- Added `LoginManager` to handle login flow
- Added `TokenManager` to handle access token management 

#### Ride Request Widget
Introducing the **Ride Request Widget**. Allows for an end to end Uber experience without leaving your application.

- Requires the `ride_widgets` scope
- Base view is `RideRequestView`
- `RideRequestViewController` & `ModalRideRequestViewController` for easy implementation that handles presenting login to the user

#### RideParameters
All ride requests are now specified by a `RideParameters` object. It allows you to set pickup/dropoff location, nickname, formatted address & product ID. Use the `RideParametersBuilder` to easily create `RideParameters` objects

#### RideRequestButton Updates
`RequestButton` has been renamed to `RideRequestButton`

`RideRequestButton` now works by using a `RideParameters` and a `RequestingBehavior`. The `RideParameters` defines the parameters for the ride and the `requestingBehavior` defines how to execute it.
Currently available `requestingBehaviors` are:

- `DeeplinkRequestingBehavior`
  - Deeplinks into the Uber app to request a ride
- `RideRequestViewRequestingBehavior`
  - Presents the **Ride Request Widget** modally in your app to provide and end to end Uber experience

### Fixed

- [Issue #13](https://github.com/uber/rides-ios-sdk/issues/13) Using CLLocation for ride parameters
- [Issue #16](https://github.com/uber/rides-ios-sdk/issues/16) Added new Uber logo for `RideRequestButton`

### Breaking
- `ClientID` must now be set in your app's `Info.plist` under the `UberClientID` key
- `RequestButton` --> `RideRequestButton`
  - Removed `init(colorStyle: RequestButtonColorStyle)` use `init(rideParameters: RideParameters, requestingBehavior: RideRequesting)`
  - Removed all setting parameter methods (`setPickupLocation()`, `setDropoffLocation()`, ect) use a `RideParameters` object instead
  - Removed `RequestButtonError`, only used to indicate no `ClientID` which is now handled by `Configuration`
  - `uberButtonTapped()` no longer public
- `RequestDeeplink`
  - Removed `init(withClientID: String, fromSource: SourceParameter)` use `init(rideParameters: RideParameters)` instead
  - Removed all setting parameter methods (`setPickupLocation()`, `setDropoffLocation`, ect) use a `RideParameters` object instead
  - `SourceParameter` removed
- Removed Carthage support


## [0.3.1] 2016-02-11
### Fixed
- [Issue #12](https://github.com/uber/rides-ios-sdk/issues/12) where there's a "&" missing in the user-agent query item.

## [0.3.0] 2016-02-01
### Breaking
- Change function signature of `setPickupLocationWithLatitude:longitude:nickname:address:` and `setDropoffLocationWithLatitude:longitude:nickname:address:` in `RequestButton` and `RequestDeeplink` to accept `Double` for latitude and longitude parameters instead of `String`.

## [0.2.1] 2016-01-26
### Fixed
- [Issue #8](https://github.com/uber/rides-ios-sdk/issues/8) where manual integration of SDK didn't allow use of resources.

## [0.2.0] 2016-01-15
### Added
- Localization of request button text for zh-Hans and zh-Hant.

### Fixed
- [Issue #6](https://github.com/uber/rides-ios-sdk/issues/6) where custom pick-up location is ignored and reset to current location.

## [0.1.1] 2015-12-02
- Initial version.
