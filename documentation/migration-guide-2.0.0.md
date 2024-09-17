# Uber iOS SDK 2.0.0 - Migration Guide
The Uber Rides SDK has been revamped and renamed to the Uber iOS SDK. Among other things, this new release includes a simplified API, better security for mobile OAuth, and updated platform support.

There are a few breaking changes that must be handled when updating the SDK. This guide will help you navigate the major code changes necessary to make the upgrade.

## New + Updated Features
### Swift Package Manager Support
Swift Package Manager is now the preferred way to integrate the Uber iOS SDK. Support for other third party package managers has been dropped for this release.

### Improved API
Authenticating with Uber has now been moved behind a simplified API. Now, less setup and state management is required from the caller.

### Auth Code Grant Flow + PKCE
The Authorization Code Grant Flow is now the default method for requesting auth credentials. In addition, support for PKCE and client access token exchange has been added.

Support for the Implicit Grand Flow has been removed.

### Prefill User Information
A convenient growth feature has been added for in app authentication. Supply optional user information to be prefilled on the signup + login page when asking the user to authenticate.

### Sample App Improvements
A brand new [sample app](../examples/UberSDK/README.md) has been provided. Use it as a playground to test your app's functionality.

## Migrating from 0.1x

### Info.plist Keys
The keys used to identify your app's credentials have changed in this release.

Previously, top-level `UberClientID` and `UberDisplayName` keys were used.
```
<key>UberClientID</key>
<string>[ClientID]</string>
<key>UberServerToken</key>
<string>[Server Token]</string>
<key>UberDisplayName</key>
<string>[App Name]</string>
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>uber</string>
    <string>uberauth</string>
</array>
```

These keys have been moved under a parent `Uber` key.


Note that `LSApplicationQueriesSchemes` remains top level, however:

* UberClientID -> Uber/ClientID
* UberDisplayName -> Uber/DisplayName


```
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>uber</string>
    <string>uberauth</string>
    <string>ubereats</string>
    <string>uberdriver</string>
</array>
<key>Uber</key>
<dict>
    <key>ClientID</key>
    <string>[Client ID]</string>
    <key>DisplayName</key>
    <string>[App Name]</string>
</dict>
```


### Authenticating

Previously, to initiate auth, the LoginManager was accessed directly. This can no longer be done and auth must now be initiated using the `UberAuth.login` static method.

Before:
```
let requestedScopes = [UberScope.request, UberScope.allTrips]
let loginManager = LoginManager(...)

loginManager.login(
    requestedScopes: requestedScopes,
    presentingViewController: self
) { (accessToken, error) -> () in
    // Use access token or handle error
}
```

After:
```
let context = AuthContext(
    authDestination: authDestination, // .native or .inApp
    authProvider: authProvider, // .authorizationCode
    prefill: prefill
)

UberAuth.login(
    context: context,
    completion: { result in
        // Handle Result<Client>
    }
)
```

### Response Types
The auth API no longer response directly with an access token. Now, the login response will come in the form of a Result type either containing a value of type `Client` or an error of type `UberAuthError`.

The Client type contains the following properties:
| Property  | Type | Description |
| ------------- | ------------- | ------------- |
| authorizationCode  | String? | The authorization code received from the authorization server. If this property is non-nil, all other properties will be nil. |
| accessToken | String? | The access token issued by the authorization server. This property will only be populated if token exchange is enabled. |
| refreshToken | String? | The type of the token issued. |
| tokenType | String? | The type of the token issued. |
| expiresIn | Int? | A token which can be used to obtain new access tokens. |
| scope | [String]? | A comma separated list of scopes requested by the client. |


and the UberAuthError cases are defined [here](../Sources/UberAuth/Errors/UberAuthError.swift)

To get auth credentials in the login callback, check the authorizationCode or accessToken properties on the client object.

Before:
```
loginManager.login(
    requestedScopes: requestedScopes,
    presentingViewController: self
) { (accessToken, error) -> () in
    print(accessToken ?? "none") // Prints the access token
}
```

After:
```
UberAuth.login { result in
    switch result {
    case .success(let client):
        print(client.accessToken ?? "none")  // Prints the access token
    case .failure(let error):
        // Handle UberAuthError
        break
    }
}
```

### Handling Responses
Previously, the UberAppDelegate API was used to pass through URLs entering the app. This API has been transitioned to the UberAuth interface.

Before:
```
func application(_ app: UIApplication,
                 open url: URL,
                 options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
    let handledUberURL = UberAppDelegate.shared.application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplicationOpenURLOptionsKey.annotation] as Any)

    return handledUberURL
}
```

After:
```
func application(_ app: UIApplication,
                 open url: URL,
                 options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {

    // If handled == true, UberAuth was able to accept the url
    if let handled = UberAuth.handle(url) {
        return true
    }
    ...
}
```
