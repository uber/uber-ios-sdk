//
//  RideRequestViewErrorType.swift
//  UberRides
//
//  Copyright © 2016 Uber Technologies, Inc. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

/**
Possible errors that can occur in the RideRequestView.

- accessTokenMissing:         There is no access token to make the request with
- accessTokenExpired:         Access token has expired.
- invalidRequest:             The requested endpoint was invalid
- networkError:               A network error occured
- notSupported:               The functionality attempted is not supported on the current device
- unknown:                    Unknown error occured.
- Warning: The Ride Request Widget is deprecated, and will no longer work for new apps.
Existing apps have until 05/31/2018 to migrate. See the Uber API Changelog for more details.
*/
@objc public enum RideRequestViewErrorType: Int {
    case accessTokenExpired
    case accessTokenMissing
    case invalidRequest
    case networkError
    case notSupported
    case unknown
    
    func toString() -> String {
        switch self {
        case .accessTokenExpired:
            return "unauthorized"
        case .accessTokenMissing:
            return "no_access_token"
        case .invalidRequest:
            return "invalid_request"
        case .networkError:
            return "network_error"
        case .notSupported:
            return "not_supported"
        case .unknown:
            return "unknown"
        }
    }
}
