//
//  EndpointsManager.swift
//  UberRides
//
//  Copyright © 2015 Uber Technologies, Inc. All rights reserved.
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

import UIKit

/**
 *  Protocol for all endpoints to conform to.
 */
protocol UberAPI {
    var HTTPMethod: Method { get }
    var path: String { get }
    var query: [NSURLQueryItem] { get }
    var host: String { get}
}

extension UberAPI {
    var host: String {
        if Configuration.getSandboxEnabled() {
            switch Configuration.getRegion() {
            case .China:
                return "https://sandbox-api.uber.com.cn"
            case .Default:
                return "https://sandbox-api.uber.com"
            }
        } else {
            switch Configuration.getRegion() {
            case .China:
                return "https://api.uber.com.cn"
            case .Default:
                return "https://api.uber.com"
            }
        }
    }
}

/**
 Enum for HTTPMethods
 */
enum Method: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case PATCH = "PATCH"
    case DELETE = "DELETE"
}

/**
 Helper function to build array of NSURLQueryItems. A key-value pair with an empty string value is ignored.
 
 - parameter queries: tuples of key-value pairs
 - returns: an array of NSURLQueryItems
 */
func queryBuilder(queries: (name: String, value: String)...) -> [NSURLQueryItem] {
    var queryItems = [NSURLQueryItem]()
    for query in queries {
        if query.name.isEmpty || query.value.isEmpty {
            continue
        }
        queryItems.append(NSURLQueryItem(name: query.name, value: query.value))
    }
    return queryItems
}

/**
 Endpoints related to components.
 - RideRequestWidget: Ride Request Widget endpoint.
 */
enum Components: UberAPI {
    case RideRequestWidget(rideParameters: RideParameters?)
    
    var HTTPMethod: Method {
        switch self {
        case .RideRequestWidget:
            return .GET
        }
    }
    
    var host: String {
        switch Configuration.getRegion() {
        case .China:
            return "https://components.uber.com.cn"
        case .Default:
            return "https://components.uber.com"
        }
    }
    
    var path: String {
        switch self {
        case .RideRequestWidget:
            return "/rides/"
        }
    }
    
    var query: [NSURLQueryItem] {
        switch self {
        case .RideRequestWidget(let rideParameters):
            let environment = Configuration.getSandboxEnabled() ? "sandbox" : "production"
            var queryItems = queryBuilder( ("env", "\(environment)") )
            
            if let rideParameters = rideParameters {
                do {
                    let url = try RequestURLUtil.buildURL(rideParameters)
                    if let urlComponents = NSURLComponents(URL: url, resolvingAgainstBaseURL: false),
                        let items = urlComponents.queryItems {
                            queryItems.appendContentsOf(items)
                    }
                } catch {
                    return queryItems
                }
            }
            return queryItems
        }
    }
}

/**
 OAuth endpoints.
 
 - Login: Used to login user and request access to specified scopes via implicit grant.
 */
enum OAuth: UberAPI {
    case Login(clientID: String, scopes: [RidesScope], redirect: String)
    
    var HTTPMethod: Method {
        switch self {
        case .Login:
            return .GET
        }
    }
    
    var host: String {
        return regionHostString()
    }
    
    func regionHostString(region: Region = Configuration.getRegion()) -> String {
        switch region {
        case .China:
            return "https://login.uber.com.cn"
        case .Default:
            return "https://login.uber.com"
        }
    }
    
    var path: String {
        switch self {
        case .Login:
            return "/oauth/v2/authorize"
        }
    }
    
    var query: [NSURLQueryItem] {
        switch self {
        case .Login(let clientID, let scopes, let redirect):
            
            return queryBuilder(
                ("scope", scopes.toRidesScopeString()),
                ("client_id", clientID),
                ("redirect_uri", redirect),
                ("response_type", "token"),
                ("show_fb", "false"))
        }
    }
}
