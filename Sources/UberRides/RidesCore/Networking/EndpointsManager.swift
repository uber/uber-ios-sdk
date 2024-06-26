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
import UberCore

/// Convenience enum for managing versions of resources.
private enum Resources: String {
    case estimates = "estimates"
    case history = "history"
    case me = "me"
    case paymentMethod = "payment-methods"
    case places = "places"
    case products = "products"
    case request = "requests"
    
    private var version: String {
        switch self {
        case .estimates: return "v1.2"
        case .history: return "v1.2"
        case .me: return "v1.2"
        case .paymentMethod: return "v1.2"
        case .places: return "v1.2"
        case .products: return "v1.2"
        case .request: return "v1.2"
        }
    }
    
    fileprivate var basePath: String {
        return "/\(version)/\(rawValue)"
    }
}

/**
 Endpoints related to components.
 - RideRequestWidget: Ride Request Widget endpoint.
 - Warning: The Ride Request Widget is deprecated, and will no longer work for new apps.
 Existing apps have until 05/31/2018 to migrate. See the Uber API Changelog for more details.
 */
enum Components: APIEndpoint {
    case rideRequestWidget(rideParameters: RideParameters?)
    
    var method: UberHTTPMethod {
        switch self {
        case .rideRequestWidget:
            return .get
        }
    }
    
    var host: String {
        return "https://components.uber.com"
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
            let environment = Configuration.shared.isSandbox ? "sandbox" : "production"
            var queryItems = queryBuilder( ("env", "\(environment)") )
            
            if let rideParameters = rideParameters {
                queryItems.append(contentsOf: RequestURLUtil.buildRequestQueryParameters(rideParameters))
            }
            
            return queryItems
        }
    }
}

/**
 API endpoints for the Products resource.
 
 - GetAll:     Returns information about the Uber products offered at a given location (lat, long).
 - GetProduct: Returns information about the Uber product specified by product ID.
 */
enum Products: APIEndpoint {
    case getAll(location: CLLocation)
    case getProduct(productID: String)
    
    var method: UberHTTPMethod {
        switch self {
        case .getAll:
            fallthrough
        case .getProduct:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .getAll:
            return Resources.products.basePath
        case .getProduct(let productID):
            return "\(Resources.products.basePath)/\(productID)"
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
enum Estimates: APIEndpoint {
    case price(startLocation: CLLocation, endLocation: CLLocation)
    case time(location: CLLocation, productID: String?)
    
    var method: UberHTTPMethod {
        switch self {
        case .price:
            fallthrough
        case .time:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .price:
            return "\(Resources.estimates.basePath)/price"
        case .time:
            return "\(Resources.estimates.basePath)/time"
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
enum History: APIEndpoint {
    case get(offset: Int?, limit: Int?)
    
    var method: UberHTTPMethod {
        switch self {
        case .get:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .get:
            return Resources.history.basePath
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
enum Me: APIEndpoint {
    case userProfile
    
    var method: UberHTTPMethod {
        switch self {
        case .userProfile:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .userProfile:
            return Resources.me.basePath
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
enum Requests: APIEndpoint {
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
            return RideRequestDataBuilder(rideParameters: rideParameters).build()
        case .getCurrent:
            fallthrough
        case .getRequest:
            return nil
        case .make(let rideParameters):
            return RideRequestDataBuilder(rideParameters: rideParameters).build()
        case .patchCurrent(let rideParameters):
            return RideRequestDataBuilder(rideParameters: rideParameters).build()
        case .patchRequest(_, let rideParameters):
            return RideRequestDataBuilder(rideParameters: rideParameters).build()
        case .rideMap:
            return nil
        case .rideReceipt:
            return nil
        }
    }
    
    var headers: [String : String]? {
        return ["Content-Type": "application/json"]
    }
    
    var method: UberHTTPMethod {
        switch self {
        case .deleteCurrent:
            fallthrough
        case .deleteRequest:
            return .delete
        case .estimate:
            return .post
        case .getCurrent:
            fallthrough
        case .getRequest:
            return .get
        case .make:
            return .post
        case .patchCurrent:
            fallthrough
        case .patchRequest:
            return .patch
        case .rideMap:
            return .get
        case .rideReceipt:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .deleteCurrent:
            return "\(Resources.request.basePath)/current"
        case .deleteRequest(let requestID):
            return "\(Resources.request.basePath)/\(requestID)"
        case .estimate:
            return "\(Resources.request.basePath)/estimate"
        case .getCurrent:
            return "\(Resources.request.basePath)/current"
        case .getRequest(let requestID):
            return "\(Resources.request.basePath)/\(requestID)"
        case .make:
            return Resources.request.basePath
        case .patchCurrent:
            return "\(Resources.request.basePath)/current"
        case .patchRequest(let requestID, _):
            return "\(Resources.request.basePath)/\(requestID)"
        case .rideMap(let requestID):
            return "\(Resources.request.basePath)/\(requestID)/map"
        case .rideReceipt(let requestID):
            return "\(Resources.request.basePath)/\(requestID)/receipt"
        }
    }
    
    var query: [URLQueryItem] {
        return []
    }
}

enum Payment: APIEndpoint {
    case getMethods
    
    var body: Data? {
        return nil
    }
    
    var method: UberHTTPMethod {
        return .get
    }
    
    var path: String {
        return Resources.paymentMethod.basePath
    }
    
    var query: [URLQueryItem] {
        return []
    }
}

enum Places: APIEndpoint {
    case getPlace(placeID: String)
    case putPlace(placeID: String, address: String)
    
    var body: Data? {
        switch self {
        case .getPlace:
            return nil
        case .putPlace(_, let address):
            do {
                let data = try JSONSerialization.data(withJSONObject: ["address": address], options: [])
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
            return ["Content-Type": "application/json"]
        }
    }
    
    var method: UberHTTPMethod {
        switch self {
        case .getPlace:
            return .get
        case .putPlace:
            return .put
        }
    }
    
    var path: String {
        switch self {
        case .getPlace(let placeID):
            return "\(Resources.places.basePath)/\(placeID)"
        case .putPlace(let placeID, _):
            return "\(Resources.places.basePath)/\(placeID)"
        }
    }
    
    var query: [URLQueryItem] {
        return []
    }
}
