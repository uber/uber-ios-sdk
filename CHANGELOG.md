# Change Log

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
