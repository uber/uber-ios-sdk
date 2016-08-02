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

import CoreLocation

/**
 *  Protocol for all endpoints to conform to.
 */
protocol UberAPI {
    var body: NSData? { get }
    var headers: [String: String]? { get }
    var host: String { get}
    var method: Method { get }
    var path: String { get }
    var query: [NSURLQueryItem] { get }
}

extension UberAPI {
    var body: NSData? {
        return nil
    }
    
    var headers: [String: String]? {
        return nil
    }
    
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
 Enum for HTTPHeaders.
 */
enum Header: String {
    case Authorization = "Authorization"
    case ContentType = "Content-Type"
}

/// Convenience enum for managing versions of resources.
private enum Resources: String {
    case Estimates = "estimates"
    case History = "history"
    case Me = "me"
    case PaymentMethod = "payment-methods"
    case Places = "places"
    case Products = "products"
    case Request = "requests"
    
    private var version: String {
        switch self {
        case .Estimates: return "v1"
        case .History: return "v1.2"
        case .Me: return "v1"
        case .PaymentMethod: return "v1"
        case .Places: return "v1"
        case .Products: return "v1"
        case .Request: return "v1"
        }
    }
    
    private var basePath: String {
        return "/\(version)/\(rawValue)"
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
    
    var method: Method {
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
                queryItems.appendContentsOf(RequestURLUtil.buildRequestQueryParameters(rideParameters))
            }
            
            return queryItems
        }
    }
}

/**
 OAuth endpoints.
 
 - ImplicitLogin: Used to login user and request access to specified scopes via implicit grant.
 - AuthorizationCodeLogin: Used to login user and request access to specified scopes via authorization code grant.
 - Refresh: Used to refresh an access token that has been aquired via SSO
 */
enum OAuth: UberAPI {
    case ImplicitLogin(clientID: String, scopes: [RidesScope], redirect: String)
    case AuthorizationCodeLogin(clientID: String, redirect: String, scopes: [RidesScope], state: String?)
    case Refresh(clientID: String, refreshToken: String)
    
    var method: Method {
        switch self {
        case .ImplicitLogin:
            fallthrough
        case .AuthorizationCodeLogin:
            return .GET
        case .Refresh:
            return .POST
        }
    }
    
    var host: String {
        return OAuth.regionHostString()
    }

    var body: NSData? {
        switch self {
        case .Refresh(let clientID, let refreshToken):
            let query = queryBuilder(
                ("client_id", clientID),
                ("refresh_token", refreshToken)
            )
            let components = NSURLComponents()
            components.queryItems = query
            return components.query?.dataUsingEncoding(NSUTF8StringEncoding)
        default:
            return nil
        }
    }
    
    static func regionHostString(region: Region = Configuration.getRegion()) -> String {
        switch region {
        case .China:
            return "https://login.uber.com.cn"
        case .Default:
            return "https://login.uber.com"
        }
    }
    
    var path: String {
        switch self {
        case .ImplicitLogin:
            fallthrough
        case .AuthorizationCodeLogin:
            return "/oauth/v2/authorize"
        case .Refresh:
            return "/oauth/v2/mobile/token"
        }
    }
    
    var query: [NSURLQueryItem] {
        switch self {
        case .ImplicitLogin(let clientID, let scopes, let redirect):
            var loginQuery = baseLoginQuery(clientID, redirect: redirect, scopes: scopes)
            let additionalQueryItems = queryBuilder(("response_type", "token"))
            
            loginQuery.appendContentsOf(additionalQueryItems)
            return loginQuery
        case .AuthorizationCodeLogin(let clientID, let redirect, let scopes, let state):
            var loginQuery = baseLoginQuery(clientID, redirect: redirect, scopes: scopes)
            let additionalQueryItems = queryBuilder(("response_type", "code"),
                                          ("state", state ?? ""))
            loginQuery.appendContentsOf(additionalQueryItems)
            return loginQuery
        case .Refresh:
            return queryBuilder()
        }
    }
    
    func baseLoginQuery(clientID: String, redirect: String, scopes: [RidesScope]) -> [NSURLQueryItem] {
        
        return queryBuilder(
            ("scope", scopes.toRidesScopeString()),
            ("client_id", clientID),
            ("redirect_uri", redirect),
            ("show_fb", "false"),
            ("signup_params", createSignupParameters()))
    }
    
    private func createSignupParameters() -> String {
        let signupParameters = [ "redirect_to_login" : true ]
        do {
            let json = try NSJSONSerialization.dataWithJSONObject(signupParameters, options: NSJSONWritingOptions(rawValue: 0))
            return json.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding76CharacterLineLength)
        } catch _ as NSError {
            return ""
        }
    }
}

/**
 API endpoints for the Products resource.
 
 - GetAll:     Returns information about the Uber products offered at a given location (lat, long).
 - GetProduct: Returns information about the Uber product specified by product ID.
 */
enum Products: UberAPI {
    case GetAll(location: CLLocation)
    case GetProduct(productID: String)
    
    var method: Method {
        switch self {
        case .GetAll:
            fallthrough
        case .GetProduct:
            return .GET
        }
    }
    
    var path: String {
        switch self {
        case .GetAll:
            return Resources.Products.basePath
        case .GetProduct(let productID):
            return "\(Resources.Products.basePath)/\(productID)"
        }
    }
    
    var query: [NSURLQueryItem] {
        switch self {
        case .GetAll(let location):
            return queryBuilder(
            ("latitude", "\(location.coordinate.latitude)"),
            ("longitude", "\(location.coordinate.longitude)"))
        case .GetProduct:
            return queryBuilder()
        }
    }
}

/**
 API Endpoints for the Estimates resource.
 
 - Price: Returns an estimated range for each product offered between two locations (lat, long).
 - Time:  Returns ETAs for all products offered at a given location (lat, long).
 */
enum Estimates: UberAPI {
    case Price(startLocation: CLLocation, endLocation: CLLocation)
    case Time(location: CLLocation, productID: String?)
    
    var method: Method {
        switch self {
        case .Price:
            fallthrough
        case .Time:
            return .GET
        }
    }
    
    var path: String {
        switch self {
        case .Price:
            return "\(Resources.Estimates.basePath)/price"
        case .Time:
            return "\(Resources.Estimates.basePath)/time"
        }
    }
    
    var query: [NSURLQueryItem] {
        switch self {
        case .Price(let startLocation, let endLocation):
            return queryBuilder(
            ("start_latitude", "\(startLocation.coordinate.latitude)"),
            ("start_longitude", "\(startLocation.coordinate.longitude)"),
            ("end_latitude", "\(endLocation.coordinate.latitude)"),
            ("end_longitude", "\(endLocation.coordinate.longitude)"))
        case .Time(let location, let productID):
            return queryBuilder(
            ("start_latitude", "\(location.coordinate.latitude)"),
            ("start_longitude", "\(location.coordinate.longitude)"),
            ("product_id", productID == nil ? "" : "\(productID!)"))
        }
    }
}

/**
 API Endpoints for the History v1.2 resource.
 
 - Get: Returns limited data about a user's lifetime activity with Uber.
 */
enum History: UberAPI {
    case Get(offset: Int?, limit: Int?)
    
    var method: Method {
        switch self {
        case .Get:
            return .GET
        }
    }
    
    var path: String {
        switch self {
        case .Get:
            return Resources.History.basePath
        }
    }
    
    var query: [NSURLQueryItem] {
        switch self {
        case .Get(let offset, let limit):
            return queryBuilder(
            ("offset", offset == nil ? "" : "\(offset!)"),
            ("limit", limit == nil ? "" : "\(limit!)"))
        }
    }
}

/**
 API Endpoints for the Me resource.
 
 - UserProfile: Returns information about the Uber user that has authorized the application.
 */
enum Me: UberAPI {
    case UserProfile
    
    var method: Method {
        switch self {
        case .UserProfile:
            return .GET
        }
    }
    
    var path: String {
        switch self {
        case .UserProfile:
            return Resources.Me.basePath
        }
    }
    
    var query: [NSURLQueryItem] {
        switch self {
        case .UserProfile:
            return queryBuilder()
        }
    }
}

/**
 API endpoints for the Requests resource.
 
 - Make:       Request a ride on behalf of Uber user.
 - GetCurrent: Returns real-time details for an ongoing trip.
 - GetRequest: Get the status of an ongoing or completed trip that was created using the Ride Request endpoint.
 - Estimate:   Gets an estimate for a ride given the desired product, start, and end locations.
 */
enum Requests: UberAPI {
    case DeleteCurrent
    case DeleteRequest(requestID: String)
    case Estimate(rideParameters: RideParameters)
    case GetCurrent
    case GetRequest(requestID: String)
    case Make(rideParameters: RideParameters)
    case PatchCurrent(rideParameters: RideParameters)
    case PatchRequest(requestID: String, rideParameters: RideParameters)
    case RideMap(requestID: String)
    case RideReceipt(requestID: String)
    
    var body: NSData? {
        switch self {
        case DeleteCurrent:
            fallthrough
        case .DeleteRequest:
            return nil
        case .Estimate(let rideParameters):
            return RideRequestDataBuilder(rideParameters: rideParameters).build()
        case .GetCurrent:
            fallthrough
        case .GetRequest:
            return nil
        case .Make(let rideParameters):
            return RideRequestDataBuilder(rideParameters: rideParameters).build()
        case PatchCurrent(let rideParameters):
            return RideRequestDataBuilder(rideParameters: rideParameters).build()
        case .PatchRequest(_, let rideParameters):
            return RideRequestDataBuilder(rideParameters: rideParameters).build()
        case .RideMap:
            return nil
        case .RideReceipt:
            return nil
        }
    }
    
    var headers: [String : String]? {
        return [Header.ContentType.rawValue: "application/json"]
    }
    
    var method: Method {
        switch self {
        case .DeleteCurrent:
            fallthrough
        case .DeleteRequest:
            return .DELETE
        case .Estimate:
            return .POST
        case .GetCurrent:
            fallthrough
        case .GetRequest:
            return .GET
        case .Make:
            return .POST
        case .PatchCurrent:
            fallthrough
        case .PatchRequest:
            return .PATCH
        case .RideMap:
            return .GET
        case .RideReceipt:
            return .GET
        }
    }
    
    var path: String {
        switch self {
        case .DeleteCurrent:
            return "\(Resources.Request.basePath)/current"
        case .DeleteRequest(let requestID):
            return "\(Resources.Request.basePath)/\(requestID)"
        case .Estimate:
            return "\(Resources.Request.basePath)/estimate"
        case .GetCurrent:
            return "\(Resources.Request.basePath)/current"
        case .GetRequest(let requestID):
            return "\(Resources.Request.basePath)/\(requestID)"
        case .Make:
            return Resources.Request.basePath
        case .PatchCurrent:
            return "\(Resources.Request.basePath)/current"
        case .PatchRequest(let requestID, _):
            return "\(Resources.Request.basePath)/\(requestID)"
        case .RideMap(let requestID):
            return "\(Resources.Request.basePath)/\(requestID)/map"
        case .RideReceipt(let requestID):
            return "\(Resources.Request.basePath)/\(requestID)/receipt"
        }
    }
    
    var query: [NSURLQueryItem] {
        return []
    }
}

enum Payment: UberAPI {
    case GetMethods
    
    var body: NSData? {
        return nil
    }
    
    var method: Method {
        return .GET
    }
    
    var path: String {
        return Resources.PaymentMethod.basePath
    }
    
    var query: [NSURLQueryItem] {
        return []
    }
}

enum Places: UberAPI {
    case GetPlace(placeID: String)
    case PutPlace(placeID: String, address: String)
    
    var body: NSData? {
        switch self {
        case .GetPlace:
            return nil
        case .PutPlace(_, let address):
            do {
                let data = try NSJSONSerialization.dataWithJSONObject(["address": address], options: .PrettyPrinted)
                return data
            } catch { }
            return nil
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .GetPlace:
            return nil
        case .PutPlace:
            return [Header.ContentType.rawValue: "application/json"]
        }
    }
    
    var method: Method {
        switch self {
        case .GetPlace:
            return .GET
        case .PutPlace:
            return .PUT
        }
    }
    
    var path: String {
        switch self {
        case .GetPlace(let placeID):
            return "\(Resources.Places.basePath)/\(placeID)"
        case .PutPlace(let placeID, _):
            return "\(Resources.Places.basePath)/\(placeID)"
        }
    }
    
    var query: [NSURLQueryItem] {
        return []
    }
}
