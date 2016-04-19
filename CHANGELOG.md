# Change Log

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
