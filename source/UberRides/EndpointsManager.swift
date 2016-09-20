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
    var body: Data? { get }
    var headers: [String: String]? { get }
    var host: String { get}
    var method: Method { get }
    var path: String { get }
    var query: [URLQueryItem] { get }
}

extension UberAPI {
    var body: Data? {
        return nil
    }
    
    var headers: [String: String]? {
        return nil
    }
    
    var host: String {
        if Configuration.getSandboxEnabled() {
            switch Configuration.getRegion() {
            case .china:
                return "https://sandbox-api.uber.com.cn"
            case .default:
                return "https://sandbox-api.uber.com"
            }
        } else {
            switch Configuration.getRegion() {
            case .china:
                return "https://api.uber.com.cn"
            case .default:
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
    
    fileprivate var version: String {
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
    
    fileprivate var basePath: String {
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
func queryBuilder(_ queries: (name: String, value: String)...) -> [URLQueryItem] {
    var queryItems = [URLQueryItem]()
    for query in queries {
        if query.name.isEmpty || query.value.isEmpty {
            continue
        }
        queryItems.append(URLQueryItem(name: query.name, value: query.value))
    }
    return queryItems
}

/**
 Endpoints related to components.
 - RideRequestWidget: Ride Request Widget endpoint.
 */
enum Components: UberAPI {
    case rideRequestWidget(rideParameters: RideParameters?)
    
    var method: Method {
        switch self {
        case .rideRequestWidget:
            return .GET
        }
    }
    
    var host: String {
        switch Configuration.getRegion() {
        case .china:
            return "https://components.uber.com.cn"
        case .default:
            return "https://components.uber.com"
        }
    }
    
    var path: String {
        switch self {
        case .rideRequestWidget:
            return "/rides/"
        }
    }
    
    var query: [URLQueryItem] {
        switch self {
        case .rideRequestWidget(let rideParameters):
            let environment = Configuration.getSandboxEnabled() ? "sandbox" : "production"
            var queryItems = queryBuilder( ("env", "\(environment)") )
            
            if let rideParameters = rideParameters {
                queryItems += RequestURLUtil.buildRequestQueryParameters(rideParameters)
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
    case implicitLogin(clientID: String, scopes: [RidesScope], redirect: String)
    case authorizationCodeLogin(clientID: String, redirect: String, scopes: [RidesScope], state: String?)
    case refresh(clientID: String, refreshToken: String)
    
    var method: Method {
        switch self {
        case .implicitLogin:
            fallthrough
        case .authorizationCodeLogin:
            return .GET
        case .refresh:
            return .POST
        }
    }
    
    var host: String {
        return OAuth.regionHostString()
    }

    var body: Data? {
        switch self {
        case .refresh(let clientID, let refreshToken):
            let query = queryBuilder(
                ("client_id", clientID),
                ("refresh_token", refreshToken)
            )
            var components = URLComponents()
            components.queryItems = query
            return components.query?.data(using: String.Encoding.utf8)
        default:
            return nil
        }
    }
    
    static func regionHostString(_ region: Region = Configuration.getRegion()) -> String {
        switch region {
        case .china:
            return "https://login.uber.com.cn"
        case .default:
            return "https://login.uber.com"
        }
    }
    
    var path: String {
        switch self {
        case .implicitLogin:
            fallthrough
        case .authorizationCodeLogin:
            return "/oauth/v2/authorize"
        case .refresh:
            return "/oauth/v2/mobile/token"
        }
    }
    
    var query: [URLQueryItem] {
        switch self {
        case .implicitLogin(let clientID, let scopes, let redirect):
            var loginQuery = baseLoginQuery(clientID, redirect: redirect, scopes: scopes)
            let additionalQueryItems = queryBuilder(("response_type", "token"))
            
            loginQuery.append(contentsOf: additionalQueryItems)
            return loginQuery
        case .authorizationCodeLogin(let clientID, let redirect, let scopes, let state):
            var loginQuery = baseLoginQuery(clientID, redirect: redirect, scopes: scopes)
            let additionalQueryItems = queryBuilder(("response_type", "code"),
                                          ("state", state ?? ""))
            loginQuery.append(contentsOf: additionalQueryItems)
            return loginQuery
        case .refresh:
            return queryBuilder()
        }
    }
    
    func baseLoginQuery(_ clientID: String, redirect: String, scopes: [RidesScope]) -> [URLQueryItem] {
        
        return queryBuilder(
            ("scope", scopes.toRidesScopeString()),
            ("client_id", clientID),
            ("redirect_uri", redirect),
            ("show_fb", "false"),
            ("signup_params", createSignupParameters()))
    }
    
    fileprivate func createSignupParameters() -> String {
        let signupParameters = [ "redirect_to_login" : true ]
        do {
            let json = try JSONSerialization.data(withJSONObject: signupParameters, options: JSONSerialization.WritingOptions(rawValue: 0))
            return json.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength76Characters)
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
    case getAll(location: CLLocation)
    case getProduct(productID: String)
    
    var method: Method {
        switch self {
        case .getAll:
            fallthrough
        case .getProduct:
            return .GET
        }
    }
    
    var path: String {
        switch self {
        case .getAll:
            return Resources.Products.basePath
        case .getProduct(let productID):
            return "\(Resources.Products.basePath)/\(productID)"
        }
    }
    
    var query: [URLQueryItem] {
        switch self {
        case .getAll(let location):
            return queryBuilder(
            ("latitude", "\(location.coordinate.latitude)"),
            ("longitude", "\(location.coordinate.longitude)"))
        case .getProduct:
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
    case price(startLocation: CLLocation, endLocation: CLLocation)
    case time(location: CLLocation, productID: String?)
    
    var method: Method {
        switch self {
        case .price:
            fallthrough
        case .time:
            return .GET
        }
    }
    
    var path: String {
        switch self {
        case .price:
            return "\(Resources.Estimates.basePath)/price"
        case .time:
            return "\(Resources.Estimates.basePath)/time"
        }
    }
    
    var query: [URLQueryItem] {
        switch self {
        case .price(let startLocation, let endLocation):
            return queryBuilder(
            ("start_latitude", "\(startLocation.coordinate.latitude)"),
            ("start_longitude", "\(startLocation.coordinate.longitude)"),
            ("end_latitude", "\(endLocation.coordinate.latitude)"),
            ("end_longitude", "\(endLocation.coordinate.longitude)"))
        case .time(let location, let productID):
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
    case get(offset: Int?, limit: Int?)
    
    var method: Method {
        switch self {
        case .get:
            return .GET
        }
    }
    
    var path: String {
        switch self {
        case .get:
            return Resources.History.basePath
        }
    }
    
    var query: [URLQueryItem] {
        switch self {
        case .get(let offset, let limit):
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
    case userProfile
    
    var method: Method {
        switch self {
        case .userProfile:
            return .GET
        }
    }
    
    var path: String {
        switch self {
        case .userProfile:
            return Resources.Me.basePath
        }
    }
    
    var query: [URLQueryItem] {
        switch self {
        case .userProfile:
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
    case deleteCurrent
    case deleteRequest(requestID: String)
    case estimate(rideParameters: RideParameters)
    case getCurrent
    case getRequest(requestID: String)
    case make(rideParameters: RideParameters)
    case patchCurrent(rideParameters: RideParameters)
    case patchRequest(requestID: String, rideParameters: RideParameters)
    case rideMap(requestID: String)
    case rideReceipt(requestID: String)
    
    var body: Data? {
        switch self {
        case .deleteCurrent:
            fallthrough
        case .deleteRequest:
            return nil
        case .estimate(let rideParameters):
            return RideRequestDataBuilder(rideParameters: rideParameters).build() as Data?
        case .getCurrent:
            fallthrough
        case .getRequest:
            return nil
        case .make(let rideParameters):
            return RideRequestDataBuilder(rideParameters: rideParameters).build() as Data?
        case .patchCurrent(let rideParameters):
            return RideRequestDataBuilder(rideParameters: rideParameters).build() as Data?
        case .patchRequest(_, let rideParameters):
            return RideRequestDataBuilder(rideParameters: rideParameters).build() as Data?
        case .rideMap:
            return nil
        case .rideReceipt:
            return nil
        }
    }
    
    var headers: [String : String]? {
        return [Header.ContentType.rawValue: "application/json"]
    }
    
    var method: Method {
        switch self {
        case .deleteCurrent:
            fallthrough
        case .deleteRequest:
            return .DELETE
        case .estimate:
            return .POST
        case .getCurrent:
            fallthrough
        case .getRequest:
            return .GET
        case .make:
            return .POST
        case .patchCurrent:
            fallthrough
        case .patchRequest:
            return .PATCH
        case .rideMap:
            return .GET
        case .rideReceipt:
            return .GET
        }
    }
    
    var path: String {
        switch self {
        case .deleteCurrent:
            return "\(Resources.Request.basePath)/current"
        case .deleteRequest(let requestID):
            return "\(Resources.Request.basePath)/\(requestID)"
        case .estimate:
            return "\(Resources.Request.basePath)/estimate"
        case .getCurrent:
            return "\(Resources.Request.basePath)/current"
        case .getRequest(let requestID):
            return "\(Resources.Request.basePath)/\(requestID)"
        case .make:
            return Resources.Request.basePath
        case .patchCurrent:
            return "\(Resources.Request.basePath)/current"
        case .patchRequest(let requestID, _):
            return "\(Resources.Request.basePath)/\(requestID)"
        case .rideMap(let requestID):
            return "\(Resources.Request.basePath)/\(requestID)/map"
        case .rideReceipt(let requestID):
            return "\(Resources.Request.basePath)/\(requestID)/receipt"
        }
    }
    
    var query: [URLQueryItem] {
        return []
    }
}

enum Payment: UberAPI {
    case getMethods
    
    var body: Data? {
        return nil
    }
    
    var method: Method {
        return .GET
    }
    
    var path: String {
        return Resources.PaymentMethod.basePath
    }
    
    var query: [URLQueryItem] {
        return []
    }
}

enum Places: UberAPI {
    case getPlace(placeID: String)
    case putPlace(placeID: String, address: String)
    
    var body: Data? {
        switch self {
        case .getPlace:
            return nil
        case .putPlace(_, let address):
            do {
                let data = try JSONSerialization.data(withJSONObject: ["address": address], options: .prettyPrinted)
                return data
            } catch { }
            return nil
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .getPlace:
            return nil
        case .putPlace:
            return [Header.ContentType.rawValue: "application/json"]
        }
    }
    
    var method: Method {
        switch self {
        case .getPlace:
            return .GET
        case .putPlace:
            return .PUT
        }
    }
    
    var path: String {
        switch self {
        case .getPlace(let placeID):
            return "\(Resources.Places.basePath)/\(placeID)"
        case .putPlace(let placeID, _):
            return "\(Resources.Places.basePath)/\(placeID)"
        }
    }
    
    var query: [URLQueryItem] {
        return []
    }
}
