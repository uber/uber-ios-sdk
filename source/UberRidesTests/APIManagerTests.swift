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
let placeID = Place.Home

struct ExpectedEndpoint {
    static let GetProducts = "https://sandbox-api.uber.com/v1/products?latitude=\(pickupLat)&longitude=\(pickupLong)"
    static let GetProduct = "https://sandbox-api.uber.com/v1/products/\(productID)?"
    static let GetPriceEstimates = "https://sandbox-api.uber.com/v1/estimates/price?start_latitude=\(pickupLat)&start_longitude=\(pickupLong)&end_latitude=\(dropoffLat)&end_longitude=\(dropoffLong)"
    static let GetTimeEstimates = "https://sandbox-api.uber.com/v1/estimates/time?start_latitude=\(pickupLat)&start_longitude=\(pickupLong)"
    static let GetTimeEstimatesAllParams = "https://sandbox-api.uber.com/v1/estimates/time?start_latitude=\(pickupLat)&start_longitude=\(pickupLong)&product_id=\(productID)"
    static let GetHistory = "https://sandbox-api.uber.com/v1.2/history?"
    static let GetHistoryWithOffset = "https://sandbox-api.uber.com/v1.2/history?offset=\(offset)"
    static let GetHistoryWithLimit = "https://sandbox-api.uber.com/v1.2/history?limit=\(limit)"
    static let GetHistoryWithAllParameters = "https://sandbox-api.uber.com/v1.2/history?offset=\(offset)&limit=\(limit)"
    static let GetUserProfile = "https://sandbox-api.uber.com/v1/me?"
    static let PostRequest = "https://sandbox-api.uber.com/v1/requests?"
    static let GetCurrentRequest = "https://sandbox-api.uber.com/v1/requests/current?"
    static let GetRequestByID = "https://sandbox-api.uber.com/v1/requests/\(requestID)?"
    static let PostRequestEstimate = "https://sandbox-api.uber.com/v1/requests/estimate?"
    static let GetPlace = "https://sandbox-api.uber.com/v1/places/\(placeID)?"
    static let PutPlace = "https://sandbox-api.uber.com/v1/places/\(placeID)?"
    static let DeleteCurrentRequest = "https://sandbox-api.uber.com/v1/requests/current?"
    static let PatchCurrentRequest = "https://sandbox-api.uber.com/v1/requests/current?"
    static let PatchRequestByID = "https://sandbox-api.uber.com/v1/requests/\(requestID)?"
    static let DeleteRequestByID = "https://sandbox-api.uber.com/v1/requests/\(requestID)?"
    static let GetPaymentMethods = "https://sandbox-api.uber.com/v1/payment-methods?"
    static let GetRideReceipt = "https://sandbox-api.uber.com/v1/requests/\(requestID)/receipt?"
    static let GetRideMap = "https://sandbox-api.uber.com/v1/requests/\(requestID)/map?"
}

class APIManagerTests: XCTestCase {
    override func setUp() {
        super.setUp()
        Configuration.restoreDefaults()
        Configuration.setSandboxEnabled(true)
    }
    
    override func tearDown() {
        Configuration.restoreDefaults()
        super.tearDown()
    }
    
    /**
     Helper function to build a NSURLRequest from an UberAPI endpoint enum.
     
     - parameter endpoint: Endpoint that conforms to UberAPI.
     
     - returns: NSURLRequest with URL and HTTPMethod set.
     */
    func buildRequestForEndpoint(_ endpoint: UberAPI) -> URLRequest {
        let request = Request(session: nil, endpoint: endpoint)
        request.prepare()
        return request.urlRequest
    }
    
    /**
     Tests the GET /v1/products endpoint.
     */
    func testGetAllProducts() {
        let request = buildRequestForEndpoint(Products.GetAll(location: CLLocation(latitude: pickupLat, longitude: pickupLong)))
        XCTAssertEqual(request.HTTPMethod, Method.GET.rawValue)
        if let url = request.URL {
            XCTAssertEqual(url.absoluteString, ExpectedEndpoint.GetProducts)
        } else {
            XCTAssert(false)
        }
    }
    
    /**
     Tests the GET /v1/products/{product_id} endpoint.
     */
    func testGetProduct() {
        let request = buildRequestForEndpoint(Products.GetProduct(productID: productID))
        XCTAssertEqual(request.HTTPMethod, Method.GET.rawValue)
        if let url = request.URL {
            XCTAssertEqual(url.absoluteString, ExpectedEndpoint.GetProduct)
        } else {
            XCTAssert(false)
        }
    }
    
    /**
     Tests the GET /v1/estimates/price endpoint.
     */
    func testGetPriceEstimates() {
        let request = buildRequestForEndpoint(Estimates.Price(startLocation: CLLocation(latitude: pickupLat, longitude: pickupLong), endLocation: CLLocation(latitude: dropoffLat, longitude: dropoffLong)))
        XCTAssertEqual(request.HTTPMethod, Method.GET.rawValue)
        if let url = request.URL {
            XCTAssertEqual(url.absoluteString, ExpectedEndpoint.GetPriceEstimates)
        } else {
            XCTAssert(false)
        }
    }
    
    /**
     Tests the GET /v1/estimates/time endpoint with only latitude and longitude.
     */
    func testGetTimeEstimates() {
        let request = buildRequestForEndpoint(Estimates.Time(location: CLLocation(latitude: pickupLat, longitude: pickupLong), productID: nil))
        XCTAssertEqual(request.HTTPMethod, Method.GET.rawValue)
        if let url = request.URL {
            XCTAssertEqual(url.absoluteString, ExpectedEndpoint.GetTimeEstimates)
        } else {
            XCTAssert(false)
        }
    }
    
    /**
     Tests the GET /v1/estimates/time endpoint with optional parameters.
     */
    func testGetTimeEstimatesWithOptionalParameters() {
        let request = buildRequestForEndpoint(Estimates.Time(location: CLLocation(latitude: pickupLat, longitude: pickupLong), productID: productID))
        XCTAssertEqual(request.HTTPMethod, Method.GET.rawValue)
        if let url = request.URL {
            XCTAssertEqual(url.absoluteString, ExpectedEndpoint.GetTimeEstimatesAllParams)
        } else {
            XCTAssert(false)
        }
    }
    
    /**
     Tests the GET /v1.2/history endpoint without optional parameters.
     */
    func testGetHistory() {
        let request = buildRequestForEndpoint(History.Get(offset: nil, limit: nil))
        XCTAssertEqual(request.HTTPMethod, Method.GET.rawValue)
        if let url = request.URL {
            XCTAssertEqual(url.absoluteString, ExpectedEndpoint.GetHistory)
        } else {
            XCTAssert(false)
        }
    }
    
    /**
     Tests the GET /v1.2/history endpoint with optional offset and limit parameters.
     */
    func testGetHistoryWithAllParameters() {
        let request = buildRequestForEndpoint(History.Get(offset: offset, limit: limit))
        XCTAssertEqual(request.HTTPMethod, Method.GET.rawValue)
        if let url = request.URL {
            XCTAssertEqual(url.absoluteString, ExpectedEndpoint.GetHistoryWithAllParameters)
        } else {
            XCTAssert(false)
        }
    }
    
    /**
     Tests the GET /v1.2/history endpoint with offset parameter and no limit parameter.
     */
    func testGetHistoryWithOffsetParameter() {
        let request = buildRequestForEndpoint(History.Get(offset: offset, limit: nil))
        XCTAssertEqual(request.HTTPMethod, Method.GET.rawValue)
        if let url = request.URL {
            XCTAssertEqual(url.absoluteString, ExpectedEndpoint.GetHistoryWithOffset)
        } else {
            XCTAssert(false)
        }
    }
    
    /**
     Tests the GET /v1.2/history endpoint with limit parameter and no offset parameter.
     */
    func testGetHistoryWithLimitParameter() {
        let request = buildRequestForEndpoint(History.Get(offset: nil, limit: limit))
        XCTAssertEqual(request.HTTPMethod, Method.GET.rawValue)
        if let url = request.URL {
            XCTAssertEqual(url.absoluteString, ExpectedEndpoint.GetHistoryWithLimit)
        } else {
            XCTAssert(false)
        }
    }
    
    /**
     Tests the GET /v1/me endpoint.
     */
    func testGetUserProfile() {
        let request = buildRequestForEndpoint(Me.UserProfile)
        XCTAssertEqual(request.HTTPMethod, Method.GET.rawValue)
        if let url = request.URL {
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
        let rideParameters = RideParametersBuilder()
            .setPickupLocation(pickupLocation, nickname: pickupNickname, address: pickupAddress)
            .setDropoffLocation(dropoffLocation, nickname: dropoffNickname, address: dropoffAddress)
            .setProductID(productID)
            .setSurgeConfirmationID(surgeConfirm)
            .setPaymentMethod(paymentMethod)
            .build()
        
        guard let data = RideRequestDataBuilder(rideParameters: rideParameters).build() else {
            XCTAssert(false)
            return
        }
        
        var dict: NSDictionary?
        do {
            dict = try JSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as? NSDictionary
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
        let rideParameters = RideParametersBuilder().setPickupPlaceID("home").setProductID(productID).build()
        let request = buildRequestForEndpoint(Requests.Make(rideParameters: rideParameters))
        XCTAssertEqual(request.HTTPMethod, Method.POST.rawValue)
        if let url = request.URL {
            XCTAssertEqual(url.absoluteString, ExpectedEndpoint.PostRequest)
        } else {
            XCTAssert(false)
        }
        XCTAssertNotNil(request.HTTPBody)
        XCTAssertEqual(request.allHTTPHeaderFields![Header.ContentType.rawValue], "application/json")
    }
    
    /**
     Test the GET /v1/requests/current endpoint.
     */
    func testGetCurrentRequest() {
        let request = buildRequestForEndpoint(Requests.GetCurrent)
        XCTAssertEqual(request.HTTPMethod, Method.GET.rawValue)
        if let url = request.URL {
            XCTAssertEqual(url.absoluteString, ExpectedEndpoint.GetCurrentRequest)
        } else {
            XCTAssert(false)
        }
    }
    
    /**
     Tests the GET /v1/requests/{request_id} endpoint.
     */
    func testGetRequestByID() {
        let request = buildRequestForEndpoint(Requests.GetRequest(requestID: requestID))
        XCTAssertEqual(request.HTTPMethod, Method.GET.rawValue)
        if let url = request.URL {
            XCTAssertEqual(url.absoluteString, ExpectedEndpoint.GetRequestByID)
        } else {
            XCTAssert(false)
        }
    }
    
    /**
     Tests the POST /v1/requests/estimate endpoint.
     */
    func testPostRequestEstimate() {
        let rideParams = RideParametersBuilder().setPickupPlaceID("home").build()
        let request = buildRequestForEndpoint(Requests.Estimate(rideParameters: rideParams))
        XCTAssertEqual(request.HTTPMethod, "POST")
        if let url = request.URL {
            XCTAssertEqual(url.absoluteString, ExpectedEndpoint.PostRequestEstimate)
        }
        XCTAssertNotNil(request.HTTPBody)
    }
    
    /**
     Tests the GET /v1/payment-methods endpoint.
     */
    func testGetPaymentMethods() {
        let request = buildRequestForEndpoint(Payment.GetMethods)
        XCTAssertEqual(request.HTTPMethod, "GET")
        if let url = request.URL {
            XCTAssertEqual(url.absoluteString, ExpectedEndpoint.GetPaymentMethods)
        } else {
            XCTAssert(false)
        }
        XCTAssertNil(request.HTTPBody)
    }
    
    /**
     Tests the GET /v1/places/{place_id} endpoint.
     */
    func testGetPlace() {
        let placeID = Place.Home
        let request = buildRequestForEndpoint(Places.GetPlace(placeID: placeID))
        XCTAssertEqual(request.HTTPMethod, Method.GET.rawValue)
        if let url = request.URL {
            XCTAssertEqual(url.absoluteString, ExpectedEndpoint.GetPlace)
        } else {
            XCTAssert(false)
        }
        XCTAssertNil(request.HTTPBody)
    }
    
    /**
     Tests the PUT /v1/places/{place_id} endpoint.
     */
    func testPutPlace() {
        let testAddress = "testAddress"
        let placeID = Place.Home
        let request = buildRequestForEndpoint(Places.PutPlace(placeID: placeID, address: testAddress))
        XCTAssertEqual(request.HTTPMethod, Method.PUT.rawValue)
        if let url = request.URL {
            XCTAssertEqual(url.absoluteString, ExpectedEndpoint.PutPlace)
        } else {
            XCTAssert(false)
        }
        if let headers = request.allHTTPHeaderFields {
            XCTAssertEqual(headers[Header.ContentType.rawValue], "application/json")
        } else {
            XCTAssert(false)
        }
        XCTAssertNotNil(request.HTTPBody)
        
        var dictionary: NSDictionary?
        do {
            dictionary = try JSONSerialization.JSONObjectWithData(request.HTTPBody!, options: .MutableContainers) as? NSDictionary
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
        let rideParams = RideParametersBuilder().setPickupPlaceID(Place.Home).build()
        let request = buildRequestForEndpoint(Requests.PatchCurrent(rideParameters: rideParams))
        XCTAssertEqual(request.HTTPMethod, "PATCH")
        if let url = request.URL {
            XCTAssertEqual(url.absoluteString, ExpectedEndpoint.PatchCurrentRequest)
        } else {
            XCTAssert(false)
        }
        
        if let headers = request.allHTTPHeaderFields {
            XCTAssertEqual(headers[Header.ContentType.rawValue], "application/json")
        } else {
            XCTAssert(false)
        }
        
        guard let data = request.HTTPBody else {
            XCTAssert(false)
            return
        }
        
        var dict: NSDictionary?
        do {
            dict = try JSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as? NSDictionary
        } catch {
            XCTAssert(false)
        }
        
        guard let dictionary = dict else {
            XCTAssert(false)
            return
        }
        
        XCTAssertEqual(dictionary["start_place_id"] as? String, Place.Home)
    }
    
    /**
     Tests the PATCH /v1/requests/{request_id} endpoint.
     */
    func testPatchRequestByID() {
        let rideParams = RideParametersBuilder().setPickupPlaceID(Place.Home).build()
        let request = buildRequestForEndpoint(Requests.PatchRequest(requestID: requestID, rideParameters: rideParams))
        XCTAssertEqual(request.HTTPMethod, "PATCH")
        if let url = request.URL {
            XCTAssertEqual(url.absoluteString, ExpectedEndpoint.PatchRequestByID)
        } else {
            XCTAssert(false)
        }
        
        if let headers = request.allHTTPHeaderFields {
            XCTAssertEqual(headers[Header.ContentType.rawValue], "application/json")
        } else {
            XCTAssert(false)
        }
        
        guard let data = request.HTTPBody else {
            XCTAssert(false)
            return
        }
        
        var dict: NSDictionary?
        do {
            dict = try JSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as? NSDictionary
        } catch {
            XCTAssert(false)
        }
        
        guard let dictionary = dict else {
            XCTAssert(false)
            return
        }
        
        XCTAssertEqual(dictionary["start_place_id"] as? String, Place.Home)
    }
    
    /**
     Tests the DELETE /v1/requests/current endpoint.
     */
    func testDeleteCurrent() {
        let request = buildRequestForEndpoint(Requests.DeleteCurrent)
        XCTAssertEqual(request.HTTPMethod, "DELETE")
        if let url = request.URL {
            XCTAssertEqual(url.absoluteString, ExpectedEndpoint.DeleteCurrentRequest)
        } else {
            XCTAssert(false)
        }
        XCTAssertNil(request.HTTPBody)
    }
    
    /**
     Tests the DELETE /v1/requests/{request_id} endpoint.
     */
    func testDeleteRequestByID() {
        let request = buildRequestForEndpoint(Requests.DeleteRequest(requestID: requestID))
        XCTAssertEqual(request.HTTPMethod, "DELETE")
        if let url = request.URL {
            XCTAssertEqual(url.absoluteString, ExpectedEndpoint.DeleteRequestByID)
        } else {
            XCTAssert(false)
        }
        XCTAssertNil(request.HTTPBody)
    }
    
    /**
     Tests the GET /v1/requests/{request_id}/receipt endpoint.
     */
    func testGetRideReceipt() {
        let request = buildRequestForEndpoint(Requests.RideReceipt(requestID: requestID))
        XCTAssertEqual(request.HTTPMethod, Method.GET.rawValue)
        if let url = request.URL {
            XCTAssertEqual(url.absoluteString, ExpectedEndpoint.GetRideReceipt)
        } else {
            XCTAssert(false)
        }
        XCTAssertNil(request.HTTPBody)
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
        let request = buildRequestForEndpoint(Requests.RideMap(requestID: requestID))
        XCTAssertEqual(request.HTTPMethod, Method.GET.rawValue)
        if let url = request.URL {
            XCTAssertEqual(url.absoluteString, ExpectedEndpoint.GetRideMap)
        } else {
            XCTAssert(false)
        }
        XCTAssertNil(request.HTTPBody)
        if let headers = request.allHTTPHeaderFields {
            XCTAssertEqual(headers[Header.ContentType.rawValue], "application/json")
        } else {
            XCTAssert(false)
        }
    }
}
