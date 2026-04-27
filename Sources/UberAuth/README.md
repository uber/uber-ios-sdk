# Contents
1. [Prerequisites](#prerequisites)
2. [Setup](#setup)
    1. [SDK Configuration](#sdk-configuration)
3. [Authenticating](#authenticating)
    1. [Simple Login](#simple-login)
    2. [Customized Login](#customized-login)
    3. [Auth Destinations](#auth-destinations)
    4. [Auth Providers](#auth-providers)
        * [AuthorizationCodeAuthProvider](#authorizationcoreauthprovider)
    5. [Forcing Login or Consent](#forcing-login-or-consent)
    6. [Responding to Redirects](#responding-to-redirects)
        * [Using UIKit](#using-uikit)
        * [Using SwiftUI](#using-swiftui)
    7. [Exchanging Authorization Code](#exchanging-authorization-code)
    8. [Prefilling User Information](#prefilling-user-information)
    9. [Login Button](#login-button)

# Prerequisites
If you haven't already, follow the [Getting Started](../../README.md#getting-started) steps in the main README.


# Setup

## SDK Configuration
In the [Uber Developer Dashboard](https://developer.uber.com/dashboard), under the Security section, enter your application's Bundle ID in the `App Signatures` text field and tap the plus icon.

<p align="center">
    <img src="../../img/app_signatures.png?raw=true" alt="App Signatures Screenshot"/>
</p>

Next, add your application's Redirect URI to the list of URLs under `Redirect URIs`. The preferred format is `[Your App's Bundle ID]://oauth/consumer`, however any redirect URI may be used.

<p align="center">
    <img src="../../img/redirect_uri.png?raw=true" alt="Request Buttons Screenshot"/>
</p>

Once registered in the developer portal, add your redirect URI to your Xcode project's `Info.plist`. This will allow the native Uber app to redirect back to your application upon successful authentication.

```xml
<key>CFBundleURLTypes</key>
	<array>
		<dict>
			<key>CFBundleURLName</key>
			<string>[Your App's Bundle ID]</string>
			<key>CFBundleURLSchemes</key>
			<array>
				<string>[Your App's Bundle ID]</string>
			</array>
		</dict>
	</array>
<key>Uber</key>
<dict>

    ...

    <key>RedirectURI</key>
    <string>[Your Redirect URI]</string>
</dict>
```


# Authenticating

## Simple Login
To authenticate your app's user with Uber's backend, use the UberAuth API. In the simplest case, call the login method and respond to the result.

```swift
UberAuth.login { result: Result<Client, UberAuthError> in
    // Handle result
}
```

Upon success, the result of the callback will contain a `Client` object containing all credentials necessary to authenticate your user.

| Property  | Type | Description |
| ------------- | ------------- | ------------- |
| authorizationCode  | String? | The authorization code received from the authorization server. If this property is non-nil, all other properties will be nil. |
| accessToken | String? | The access token issued by the authorization server. This property will only be populated if token exchange is enabled. |
| refreshToken | String? | The type of the token issued. |
| tokenType | String? | The type of the token issued. |
| expiresIn | Int? | A token which can be used to obtain new access tokens. |
| scope | [String]? | A comma separated list of scopes requested by the client. |



Upon failure, the result will contain an error of type UberAuthError. See [Errors](./Errors/README.md) for more information.


## Customized Login

For more complicated use cases, an auth context may be supplied to the login function. Use this type to specify additional customizations for the login experience:

* [Auth Destination](#auth-destination) - Where the login should occur; in the native Uber app or inside your application.
* [Auth Provider](#auth-providers) - The type of grant flow that should be used. Authorization Code Grant Flow is the only supported type.
* [Prefill](#prefill) - Optional user information that should be prefilled when presenting the login screen.

```swift
let context = AuthContext(
    authDestination: authDestination, // .native or .inApp
    authProvider: authProvider, // .authorizationCode
    prefill: prefill
)

UberAuth.login(
    context: context,
    completion: { result in
        // Handle result
    }
)
```


## Auth Destinations

There are two locations or `AuthDestination`s where authentication can be handled.

1. `.inApp` - Presents the login screen inside the host application using a secure web browser via ASWebAuthenticationSession.
2. `.native` - Links to the native Uber app, if installed. If not installed, falls back to .inApp. By default, native will attempt to open each of the following Uber apps in the following order: Uber Rides, Uber Eats, Uber Driver. If you would like to customize this order you can supply the order in the enum case's associated value. For example:
`.native([.eats, .driver, .rides])` will prefer the Uber Eats app first, and `.native([.driver])` will only attempt to open the Uber Driver app and fall back to .inApp if unavailable.


```swift
let context = AuthContext(
    authDestination: .native([.rides]) // Only launch the Uber Rides app, fallback to inApp
)

UberAuth.login(
    context: context,
    completion: { result in
        // Handle result
    }
)
```

| In App| Native |
| -- | -- |
| <img src="../../img/in_app_auth.png?raw=true" width=200 alt="App Signatures Screenshot"/> | <img src="../../img/native_auth.png?raw=true" width=200 alt="App Signatures Screenshot"/> |

## Auth Providers

An Auth Provider supplies logic for a specific authentication grant flow. Currently, the only supported auth provider is `AuthorizationCoreAuthProvider`.

### AuthorizationCoreAuthProvider

AuthorizationCoreAuthProvider performs the Authorization Code Grant Flow as specified in the [OAuth 2.0 Framework](https://datatracker.ietf.org/doc/html/rfc6749#section-4.1). AuthorizationCoreAuthProvider is currently the only supported auth provider.

## Forcing Login or Consent
The auth provider accepts an optional `prompt` parameter that can be used to force the login screen or the consent screen to be presented.

**Note:** Login is only available for .inApp auth destinations.

```
// Will request login then show the consent screen, even if previously completed by the user
let prompt: [Prompt] = [.login, .consent]

let authProvider: AuthProviding = .authorizationCode(
    prompt: prompt
)
```

## Responding to Redirects

When using the native auth destination, your app will need to handle the callback deeplink in order to receive the users's credentials. There are multiple methods to handle this depending on your project setup.

Once handled, the original closure your supplied to the login method will be called, passing back a result with the Client object inside.

### Using UIKit:

In your **AppDelegate** class, override the `openUrl` method. Pass the incoming URL into the `UberAuth.handle` method. If the URL is valid and UberAuth is able to parse it, it will return true and you can exit early from the openURL method.

```swift
import UberAuth

final class AppDelegate: NSObject, UIApplicationDelegate {

    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {

        // If handled == true, UberAuth was able to accept the url
        if let handled = UberAuth.handle(url) {
            return true
        }
        ...
    }
}
```

### Using SwiftUI:

#### Option 1 - Using AppDelegate
You may add an AppDelegate class to your SwiftUI app and use the method above. To do so, define an AppDelegate class in your main App entry point.

```swift
@main
struct MyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    ...
}
```

Proceed with the steps above to handle incoming URLs in your AppDelegate.

#### Option 2 - onOpenURL

SwiftUI View's provide a method for intercepting incoming URLs. In your SwiftUI view, use the onOpenURL handler to be notified when your app accepts an incoming deeplink.

```swift
struct ContentView: View {

    var body: some View {
        someView
            .onOpenURL { url
                let handled = UberAuth.handle(url)
            }
    }

}
```

### Exchanging Authorization Code

In many cases, you may with to receive an access token and authorize a user inside your mobile app only, without the use of a backend service.
UberAuth supports this by allowing you to exchange the returned AuthorizationCode for an Access Token using PKCE. To do so, enable the flag `shouldExchangeAuthCode` in the AuthorizationCodeAuthProvider context.

```swift
let authProvider: AuthProviding = .authorizationCode(
    shouldExchangeAuthCode: true
)

UberAuth.login(
    context: AuthContext(
        authProvider: authProvider,
    ),
    completion: { result in
        // Handle result
    }
)
```

Upon successful authentication, the Client object returned will contain a valid Access Token and Refresh Token.

**Note:** Authorization Code **will be nil** as it has been used for the token exchange and is no longer valid.

## Prefilling User Information
The SDK supports the OpenID `login_hint` parameter for prefilling user information when authenticating with Uber.
To pass user information into the login page, ise the Prefill API when constructing the AuthContext. Partial information is accepted.

**Note:** Prefill information is only supported using the `.inApp` login type.

**Using UberAuth**
```
let prefill = Prefill(
    email: "jane@email.com",
    phoneNumber: "5555555555",
    firstName: "Jane",
    lastName: "Doe"
)

UberAuth.login(
    context: AuthContext(
        authDestination: .inApp,
        authProvider: .authorizationCode(),
        prefill: prefill
    ),
    completion: { _ in }
)
```

**Using the LoginButton / DataSource**

```
final class MyLoginButtonDataSource: LoginButtonDataSource {

    func authContext(_ button: LoginButton) -> AuthContext {
        let prefill = Prefill(
            email: "jane@email.com",
            phoneNumber: "5555555555",
            firstName: "Jane",
            lastName: "Doe"
        )

        return AuthContext(
            authDestination: .inApp,
            authProvider: .authorizationCode(),
            prefill: prefill
        )
    }
}
```


### Login Button

As a convenience, the SDK provides a `LoginButton` class that can be used to log a user in or out.

<img src="../../img/login_button.png?raw=true" width=600 alt="Login Button"/>

For simple cases, construct the button using the default initializer.
```
import UberAuth

let loginButton = LoginButton()
```


To receive the login result, conform to the `LoginButtonDelegate`.

```

loginButton.delegate = MyLoginButtonDelegate()

...

final class MyLoginButtonDelegate: LoginButtonDelegate {

    func loginButton(_ button: LoginButton, didLogoutWithSuccess success: Bool) {
        // Successful logout
    }

    func loginButton(_ button: LoginButton, didCompleteLoginWithResult result: Result<Client, UberAuthError>) {
        switch result {
        case .success(let client):
            // Handle Client response
            break
        case .failure(let error):
            // Handle UberAuthError
            break
        }
    }
}
```
