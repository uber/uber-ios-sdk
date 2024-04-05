
# Errors

All errors returned from UberAuth will be of type UberAuthError. See the tables below for information on specific errors.

## UberAuthError
| Error | Associated Value | Description |
| ----- | ------------ | ----------- |
| UberAuthError.cancelled | - | The authentication flow was aborted before completion. |
| UberAuthError.couldNotOpenApp(UberApp) | UberApp | The SDK failed to open the Uber client app. The associated value indicates which app the SDK attempted to open. |
| UberAuthError.existingAuthSession | - | An attempt to start an  authentication session was made while another session was in progress. |
| UberAuthError.invalidAuthCode | - | The authorization code was not found or is malformed. |
| UberAuthError.invalidResponse | - | The response url could not be parsed. |
| UberAuthError.invalidRequest(String) | Request url | The auth request could not be built. The associated value indicates which request failed. |
| UberAuthError.oAuth(OAuthError) | OAuthError | An OAuth standard error occurred. See [OAuthError](#oautherror) for more information on the associated error. |
| UberAuthError.other(Error) | Error | An unknown error occurred. |
| UberAuthError.serviceError | - | An error occurred when making a network request. |

## OAuthError
Standard errors, as specified in [section-4.1.2.1](https://datatracker.ietf.org/doc/html/rfc6749#section-4.1.2.1) of the OAuth 2.0 Authorization Framework.

| Error | String Value | Description |
| ----- | ------------ | ----------- |
| OAuthError.invalidRequest | invalid_request | The request is missing a required parameter, includes an invalid parameter value, includes a parameter more than once, or is otherwise malformed. |
| OAuthError.unauthorizedClient | unauthorized_client | The client is not authorized to request an authorization code using this method. |
| OAuthError.accessDenied | access_denied | The resource owner or authorization server denied the request. |
| OAuthError.unsupportedResponseType | unsupported_response_type | The authorization server does not support obtaining an authorization code using this method. |
| OAuthError.invalidScope | invalid_scope | The requested scope is invalid, unknown, or malformed. |
| OAuthError.serverError | server_error | The authorization server encountered an unexpected condition that prevented it from fulfilling the request. (This error code is needed because a 500 Internal Server Error HTTP status code cannot be returned to the client via an HTTP redirect.) |
| OAuthError.temporarilyUnavailable | temporarily_unavailable | The authorization server is currently unable to handle the request due to a temporary overloading or maintenance of the server.  (This error code is needed because a 503 Service Unavailable HTTP status code cannot be returned to the client via an HTTP redirect.) |
