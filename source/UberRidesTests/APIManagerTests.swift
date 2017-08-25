//
//  APIManagerTests.swift
//  UberRidesTests
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

import XCTest
import CoreLocation
@testable import UberRides

let offset = 1
let limit = 25
let requestID = "request1234"
let placeID = Place.home

struct ExpectedEndpoint {
    static let GetProducts = "https://sandbox-api.uber.com/v1.2/products?latitude=\(pickupLat)&longitude=\(pickupLong)"
    static let GetProduct = "https://sandbox-api.uber.com/v1.2/products/\(productID)?"
    static let GetPriceEstimates = "https://sandbox-api.uber.com/v1/estimates/price?start_latitude=\(pickupLat)&start_longitude=\(pickupLong)&end_latitude=\(dropoffLat)&end_longitude=\(dropoffLong)"
    static let GetTimeEstimates = "https://sandbox-api.uber.com/v1/estimates/time?start_latitude=\(pickupLat)&start_longitude=\(pickupLong)"
    static let GetTimeEstimatesAllParams = "https://sandbox-api.uber.com/v1/estimates/time?start_latitude=\(pickupLat)&start_longitude=\(pickupLong)&product_id=\(productID)"
    static let GetHistory = "https://sandbox-api.uber.com/v1.2/history?"
    static let GetHistoryWithOffset = "https://sandbox-api.uber.com/v1.2/history?offset=\(offset)"
    static let GetHistoryWithLimit = "https://sandbox-api.uber.com/v1.2/history?limit=\(limit)"
    static let GetHistoryWithAllParameters = "https://sandbox-api.uber.com/v1.2/history?offset=\(offset)&limit=\(limit)"
    static let GetUserProfile = "https://sandbox-api.uber.com/v1.2/me?"
    static let PostRequest = "https://sandbox-api.uber.com/v1/requests?"
    static let GetCurrentRequest = "https://sandbox-api.uber.com/v1/requests/current?"
    static let GetRequestByID = "https://sandbox-api.uber.com/v1/requests/\(requestID)?"
    static let PostRequestEstimate = "https://sandbox-api.uber.com/v1/requests/estimate?"
    static let GetPlace = "https://sandbox-api.uber.com/v1.2/places/\(placeID)?"
    static let PutPlace = "https://sandbox-api.uber.com/v1.2/places/\(placeID)?"
    static let DeleteCurrentRequest = "https://sandbox-api.uber.com/v1/requests/current?"
    static let PatchCurrentRequest = "https://sandbox-api.uber.com/v1/requests/current?"
    static let PatchRequestByID = "https://sandbox-api.uber.com/v1/requests/\(requestID)?"
    static let DeleteRequestByID = "https://sandbox-api.uber.com/v1/requests/\(requestID)?"
    static let GetPaymentMethods = "https://sandbox-api.uber.com/v1.2/payment-methods?"
    static let GetRideReceipt = "https://sandbox-api.uber.com/v1/requests/\(requestID)/receipt?"
    static let GetRideMap = "https://sandbox-api.uber.com/v1/requests/\(requestID)/map?"
}

class APIManagerTests: XCTestCase {
    override func setUp() {
        super.setUp()
        Configuration.restoreDefaults()
        Configuration.shared.isSandbox = true
    }
    
    override func tearDown() {
        Configuration.restoreDefaults()
        super.tearDown()
    }
    
    /**
     Helper function to build a NSURLRequest from an UberAPI endpoint enum.
     
     - parameter endpoint: Endpoint that conforms to UberAPI.
     
     - returns: URLRequest with URL and HTTPMethod set.
     */
    func buildRequestForEndpoint(_ endpoint: UberAPI) -> URLRequest {
        let request = Request(session: nil, endpoint: endpoint)
        XCTAssertNotNil(request, "Unable to create request")
        request?.prepare()
        return request!.urlRequest
    }
    
    /**
     Tests the GET /v1/products endpoint.
     */
    func testGetAllProducts() {
        let request = buildRequestForEndpoint(Products.getAll(location: CLLocation(latitude: pickupLat, longitude: pickupLong)))
        XCTAssertEqual(request.httpMethod, Method.get.rawValue)
        if let url = request.url {
            XCTAssertEqual(url.absoluteString, ExpectedEndpoint.GetProducts)
        } else {
            XCTAssert(false)
        }
    }
    
    /**
     Tests the GET /v1/products/{product_id} endpoint.
     */
    func testGetProduct() {
        let request = buildRequestForEndpoint(Products.getProduct(productID: productID))
        XCTAssertEqual(request.httpMethod, Method.get.rawValue)
        if let url = request.url {
            XCTAssertEqual(url.absoluteString, ExpectedEndpoint.GetProduct)
        } else {
            XCTAssert(false)
        }
    }
    
    /**
     Tests the GET /v1/estimates/price endpoint.
     */
    func testGetPriceEstimates() {
        let request = buildRequestForEndpoint(Estimates.price(startLocation: CLLocation(latitude: pickupLat, longitude: pickupLong), endLocation: CLLocation(latitude: dropoffLat, longitude: dropoffLong)))
        XCTAssertEqual(request.httpMethod, Method.get.rawValue)
        if let url = request.url {
            XCTAssertEqual(url.absoluteString, ExpectedEndpoint.GetPriceEstimates)
        } else {
            XCTAssert(false)
        }
    }
    
    /**
     Tests the GET /v1/estimates/time endpoint with only latitude and longitude.
     */
    func testGetTimeEstimates() {
        let request = buildRequestForEndpoint(Estimates.time(location: CLLocation(latitude: pickupLat, longitude: pickupLong), productID: nil))
        XCTAssertEqual(request.httpMethod, Method.get.rawValue)
        if let url = request.url {
            XCTAssertEqual(url.absoluteString, ExpectedEndpoint.GetTimeEstimates)
        } else {
            XCTAssert(false)
        }
    }
    
    /**
     Tests the GET /v1/estimates/time endpoint with optional parameters.
     */
    func testGetTimeEstimatesWithOptionalParameters() {
        let request = buildRequestForEndpoint(Estimates.time(location: CLLocation(latitude: pickupLat, longitude: pickupLong), productID: productID))
        XCTAssertEqual(request.httpMethod, Method.get.rawValue)
        if let url = request.url {
            XCTAssertEqual(url.absoluteString, ExpectedEndpoint.GetTimeEstimatesAllParams)
        } else {
            XCTAssert(false)
        }
    }
    
    /**
     Tests the GET /v1.2/history endpoint without optional parameters.
     */
    func testGetHistory() {
        let request = buildRequestForEndpoint(History.get(offset: nil, limit: nil))
        XCTAssertEqual(request.httpMethod, Method.get.rawValue)
        if let url = request.url {
            XCTAssertEqual(url.absoluteString, ExpectedEndpoint.GetHistory)
        } else {
            XCTAssert(false)
        }
    }
    
    /**
     Tests the GET /v1.2/history endpoint with optional offset and limit parameters.
     */
    func testGetHistoryWithAllParameters() {
        let request = buildRequestForEndpoint(History.get(offset: offset, limit: limit))
        XCTAssertEqual(request.httpMethod, Method.get.rawValue)
        if let url = request.url {
            XCTAssertEqual(url.absoluteString, ExpectedEndpoint.GetHistoryWithAllParameters)
        } else {
            XCTAssert(false)
        }
    }
    
    /**
     Tests the GET /v1.2/history endpoint with offset parameter and no limit parameter.
     */
    func testGetHistoryWithOffsetParameter() {
        let request = buildRequestForEndpoint(History.get(offset: offset, limit: nil))
        XCTAssertEqual(request.httpMethod, Method.get.rawValue)
        if let url = request.url {
            XCTAssertEqual(url.absoluteString, ExpectedEndpoint.GetHistoryWithOffset)
        } else {
            XCTAssert(false)
        }
    }
    
    /**
     Tests the GET /v1.2/history endpoint with limit parameter and no offset parameter.
     */
    func testGetHistoryWithLimitParameter() {
        let request = buildRequestForEndpoint(History.get(offset: nil, limit: limit))
        XCTAssertEqual(request.httpMethod, Method.get.rawValue)
        if let url = request.url {
            XCTAssertEqual(url.absoluteString, ExpectedEndpoint.GetHistoryWithLimit)
        } else {
            XCTAssert(false)
        }
    }
    
    /**
     Tests the GET /v1/me endpoint.
     */
    func testGetUserProfile() {
        let request = buildRequestForEndpoint(Me.userProfile)
        XCTAssertEqual(request.httpMethod, Method.get.rawValue)
        if let url = request.url {
            XCTAssertEqual(url.absoluteString, ExpectedEndpoint.GetUserProfile)
        } else {
            XCTAssert(false)
        }
    }
    
    /**
     Test building ride request data with all parameters.
     */
    func testRequestBuilderAllParameters() {
        let pickupLocation = CLLocation(latitude: pickupLat, longitude: pickupLong)
        let dropoffLocation = CLLocation(latitude: dropoffLat, longitude: dropoffLong)
        let rideParameters = RideParameters(pickupLocation: pickupLocation, dropoffLocation: dropoffLocation)
        rideParameters.pickupNickname = pickupNickname
        rideParameters.pickupAddress = pickupAddress
        rideParameters.dropoffNickname = dropoffNickname
        rideParameters.dropoffAddress = dropoffAddress
        rideParameters.productID = productID
        rideParameters.surgeConfirmationID = surgeConfirm
        rideParameters.paymentMethod = paymentMethod
        
        guard let data = RideRequestDataBuilder(rideParameters: rideParameters).build() else {
            XCTAssert(false)
            return
        }
        
        var dict: Dictionary<String, Any>?
        do {
            dict = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? Dictionary<String, Any>
        } catch {
            XCTAssert(false)
        }
        
        if let dictionary = dict  {
            XCTAssertEqual(dictionary["product_id"] as? String, productID)
            XCTAssertEqual(dictionary["start_latitude"] as? Double, pickupLat)
            XCTAssertEqual(dictionary["start_longitude"] as? Double, pickupLong)
            XCTAssertEqual(dictionary["start_nickname"] as? String, pickupNickname)
            XCTAssertEqual(dictionary["start_address"] as? String, pickupAddress)
            XCTAssertEqual(dictionary["end_latitude"] as? Double, dropoffLat)
            XCTAssertEqual(dictionary["end_longitude"] as? Double, dropoffLong)
            XCTAssertEqual(dictionary["end_nickname"] as? String, dropoffNickname)
            XCTAssertEqual(dictionary["end_address"] as? String, dropoffAddress)
            XCTAssertEqual(dictionary["payment_method_id"] as? String, paymentMethod)
            XCTAssertEqual(dictionary["surge_confirmation_id"] as? String, surgeConfirm)
        } else {
            XCTAssert(false)
        }
    }
    
    /**
     Test the POST /v1/requests endpoint.
     */
    func testPostRequest() {
        let rideParameters = RideParameters(pickupPlaceID: "home", dropoffPlaceID: nil)
        rideParameters.productID = productID
        let request = buildRequestForEndpoint(Requests.make(rideParameters: rideParameters))
        XCTAssertEqual(request.httpMethod, Method.post.rawValue)
        if let url = request.url {
            XCTAssertEqual(url.absoluteString, ExpectedEndpoint.PostRequest)
        } else {
            XCTAssert(false)
        }
        XCTAssertNotNil(request.httpBody)
        XCTAssertEqual(request.allHTTPHeaderFields![Header.ContentType.rawValue], "application/json")
    }
    
    /**
     Test the GET /v1/requests/current endpoint.
     */
    func testGetCurrentRequest() {
        let request = buildRequestForEndpoint(Requests.getCurrent)
        XCTAssertEqual(request.httpMethod, Method.get.rawValue)
        if let url = request.url {
            XCTAssertEqual(url.absoluteString, ExpectedEndpoint.GetCurrentRequest)
        } else {
            XCTAssert(false)
        }
    }
    
    /**
     Tests the GET /v1/requests/{request_id} endpoint.
     */
    func testGetRequestByID() {
        let request = buildRequestForEndpoint(Requests.getRequest(requestID: requestID))
        XCTAssertEqual(request.httpMethod, Method.get.rawValue)
        if let url = request.url {
            XCTAssertEqual(url.absoluteString, ExpectedEndpoint.GetRequestByID)
        } else {
            XCTAssert(false)
        }
    }
    
    /**
     Tests the POST /v1/requests/estimate endpoint.
     */
    func testPostRequestEstimate() {
        let rideParameters = RideParameters(pickupPlaceID: "home", dropoffPlaceID: nil)
        let request = buildRequestForEndpoint(Requests.estimate(rideParameters: rideParameters))
        XCTAssertEqual(request.httpMethod, "POST")
        if let url = request.url {
            XCTAssertEqual(url.absoluteString, ExpectedEndpoint.PostRequestEstimate)
        }
        XCTAssertNotNil(request.httpBody)
    }
    
    /**
     Tests the GET /v1/payment-methods endpoint.
     */
    func testGetPaymentMethods() {
        let request = buildRequestForEndpoint(Payment.getMethods)
        XCTAssertEqual(request.httpMethod, "GET")
        if let url = request.url {
            XCTAssertEqual(url.absoluteString, ExpectedEndpoint.GetPaymentMethods)
        } else {
            XCTAssert(false)
        }
        XCTAssertNil(request.httpBody)
    }
    
    /**
     Tests the GET /v1/places/{place_id} endpoint.
     */
    func testGetPlace() {
        let placeID = Place.home
        let request = buildRequestForEndpoint(Places.getPlace(placeID: placeID))
        XCTAssertEqual(request.httpMethod, Method.get.rawValue)
        if let url = request.url {
            XCTAssertEqual(url.absoluteString, ExpectedEndpoint.GetPlace)
        } else {
            XCTAssert(false)
        }
        XCTAssertNil(request.httpBody)
    }
    
    /**
     Tests the PUT /v1/places/{place_id} endpoint.
     */
    func testPutPlace() {
        let testAddress = "testAddress"
        let placeID = Place.home
        let request = buildRequestForEndpoint(Places.putPlace(placeID: placeID, address: testAddress))
        XCTAssertEqual(request.httpMethod, Method.put.rawValue)
        if let url = request.url {
            XCTAssertEqual(url.absoluteString, ExpectedEndpoint.PutPlace)
        } else {
            XCTAssert(false)
        }
        if let headers = request.allHTTPHeaderFields {
            XCTAssertEqual(headers[Header.ContentType.rawValue], "application/json")
        } else {
            XCTAssert(false)
        }
        XCTAssertNotNil(request.httpBody)
        
        var dictionary: NSDictionary?
        do {
            dictionary = try JSONSerialization.jsonObject(with: request.httpBody!, options: .mutableContainers) as? NSDictionary
        } catch {
            XCTAssert(false)
        }
        
        guard let body = dictionary else {
            XCTAssert(false)
            return
        }
        
        XCTAssertEqual(body["address"] as? String, testAddress)
    }
    
    /**
     Tests the PATCH /v1/requests/curent endpoint.
     */
    func testPatchCurrentRequest() {
        let rideParams = RideParameters(pickupPlaceID: Place.home, dropoffPlaceID: nil)
        let request = buildRequestForEndpoint(Requests.patchCurrent(rideParameters: rideParams))
        XCTAssertEqual(request.httpMethod, "PATCH")
        if let url = request.url {
            XCTAssertEqual(url.absoluteString, ExpectedEndpoint.PatchCurrentRequest)
        } else {
            XCTAssert(false)
        }
        
        if let headers = request.allHTTPHeaderFields {
            XCTAssertEqual(headers[Header.ContentType.rawValue], "application/json")
        } else {
            XCTAssert(false)
        }
        
        guard let data = request.httpBody else {
            XCTAssert(false)
            return
        }
        
        var dict: NSDictionary?
        do {
            dict = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary
        } catch {
            XCTAssert(false)
        }
        
        guard let dictionary = dict else {
            XCTAssert(false)
            return
        }
        
        XCTAssertEqual(dictionary["start_place_id"] as? String, Place.home)
    }
    
    /**
     Tests the PATCH /v1/requests/{request_id} endpoint.
     */
    func testPatchRequestByID() {
        let rideParams = RideParameters(pickupPlaceID: Place.home, dropoffPlaceID: nil)
        let request = buildRequestForEndpoint(Requests.patchRequest(requestID: requestID, rideParameters: rideParams))
        XCTAssertEqual(request.httpMethod, "PATCH")
        if let url = request.url {
            XCTAssertEqual(url.absoluteString, ExpectedEndpoint.PatchRequestByID)
        } else {
            XCTAssert(false)
        }
        
        if let headers = request.allHTTPHeaderFields {
            XCTAssertEqual(headers[Header.ContentType.rawValue], "application/json")
        } else {
            XCTAssert(false)
        }
        
        guard let data = request.httpBody else {
            XCTAssert(false)
            return
        }
        
        var dict: NSDictionary?
        do {
            dict = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary
        } catch {
            XCTAssert(false)
        }
        
        guard let dictionary = dict else {
            XCTAssert(false)
            return
        }
        
        XCTAssertEqual(dictionary["start_place_id"] as? String, Place.home)
    }
    
    /**
     Tests the DELETE /v1/requests/current endpoint.
     */
    func testDeleteCurrent() {
        let request = buildRequestForEndpoint(Requests.deleteCurrent)
        XCTAssertEqual(request.httpMethod, "DELETE")
        if let url = request.url {
            XCTAssertEqual(url.absoluteString, ExpectedEndpoint.DeleteCurrentRequest)
        } else {
            XCTAssert(false)
        }
        XCTAssertNil(request.httpBody)
    }
    
    /**
     Tests the DELETE /v1/requests/{request_id} endpoint.
     */
    func testDeleteRequestByID() {
        let request = buildRequestForEndpoint(Requests.deleteRequest(requestID: requestID))
        XCTAssertEqual(request.httpMethod, "DELETE")
        if let url = request.url {
            XCTAssertEqual(url.absoluteString, ExpectedEndpoint.DeleteRequestByID)
        } else {
            XCTAssert(false)
        }
        XCTAssertNil(request.httpBody)
    }
    
    /**
     Tests the GET /v1/requests/{request_id}/receipt endpoint.
     */
    func testGetRideReceipt() {
        let request = buildRequestForEndpoint(Requests.rideReceipt(requestID: requestID))
        XCTAssertEqual(request.httpMethod, Method.get.rawValue)
        if let url = request.url {
            XCTAssertEqual(url.absoluteString, ExpectedEndpoint.GetRideReceipt)
        } else {
            XCTAssert(false)
        }
        XCTAssertNil(request.httpBody)
        if let headers = request.allHTTPHeaderFields {
            XCTAssertEqual(headers[Header.ContentType.rawValue], "application/json")
        } else {
            XCTAssert(false)
        }
    }
    
    /**
     Tests the GET /v1/request/{request_id}/map endpoint.
     */
    func testGetRideMap() {
        let request = buildRequestForEndpoint(Requests.rideMap(requestID: requestID))
        XCTAssertEqual(request.httpMethod, Method.get.rawValue)
        if let url = request.url {
            XCTAssertEqual(url.absoluteString, ExpectedEndpoint.GetRideMap)
        } else {
            XCTAssert(false)
        }
        XCTAssertNil(request.httpBody)
        if let headers = request.allHTTPHeaderFields {
            XCTAssertEqual(headers[Header.ContentType.rawValue], "application/json")
        } else {
            XCTAssert(false)
        }
    }
}
