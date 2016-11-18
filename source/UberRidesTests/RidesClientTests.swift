//
//  RidesClientTests.swift
//  UberRidesTests
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

import XCTest
import OHHTTPStubs
import CoreLocation
@testable import UberRides

class RidesClientTests: XCTestCase {
    var client: RidesClient!
    let timeout: Double = 10
    
    override func setUp() {
        super.setUp()
        Configuration.restoreDefaults()
        Configuration.plistName = "testInfoNoServerToken"
        Configuration.bundle = NSBundle(forClass: self.dynamicType)
        Configuration.setClientID(clientID)
        Configuration.setServerToken(nil)
        Configuration.setSandboxEnabled(true)
        client = RidesClient()
    }
    
    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        Configuration.restoreDefaults()
        super.tearDown()
    }
    
    /**
     Test hasServerToken.
     */
    func testHasServerToken() {
        
        XCTAssertFalse(client.hasServerToken())
        Configuration.setServerToken(serverToken)
        client = RidesClient()
        XCTAssertTrue(client.hasServerToken())
    }
    
    /**
     Test convenience function for getting cheapest product.
     */
    func testGetCheapestProduct() {
        stub(isHost("sandbox-api.uber.com")) { _ in
            return OHHTTPStubsResponse(fileAtPath:OHPathForFile("getProducts.json", self.dynamicType)!, statusCode:200, headers:nil)
        }
        
        let expectation = expectationWithDescription("get cheapest product")
        let location = CLLocation(latitude: pickupLat, longitude: pickupLong)
        client.fetchCheapestProduct(pickupLocation: location, completion: { ridesProduct, response in
            XCTAssertNotNil(ridesProduct)
            XCTAssertEqual(ridesProduct!.name, "uberX")
            
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(timeout, handler:{ error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        })
    }
    
    /**
     Test getting all products.
     */
    func testGetProducts() {
        stub(isHost("sandbox-api.uber.com")) { _ in
            return OHHTTPStubsResponse(fileAtPath:OHPathForFile("getProducts.json", self.dynamicType)!, statusCode:200, headers:nil)
        }
        
        let expectation = expectationWithDescription("get all products")
        let location = CLLocation(latitude: pickupLat, longitude: pickupLong)
        client.fetchProducts(pickupLocation: location, completion: { products, response in
            
            XCTAssertEqual(products.count, 5)
            XCTAssertEqual(products[0].name, "uberX")
            XCTAssertEqual(products[1].name, "uberXL")
            XCTAssertEqual(products[2].name, "UberBLACK")
            XCTAssertEqual(products[3].name, "UberSUV")
            XCTAssertEqual(products[4].name, "uberTAXI")
            
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(timeout, handler:{ error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        })
    }
    
    /**
     Test get product by ID.
     */
    func testGetProductByID() {
        stub(isHost("sandbox-api.uber.com")) { _ in
            return OHHTTPStubsResponse(fileAtPath:OHPathForFile("getProductID.json", self.dynamicType)!, statusCode:200, headers:nil)
        }
        
        let expectation = expectationWithDescription("get product by id")
        
        client.fetchProduct(productID, completion: { product, response in
            
            XCTAssertNotNil(product)
            XCTAssertEqual(product!.name, "UberBLACK")
            XCTAssertEqual(product!.capacity, 4)
            
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(timeout, handler:{ error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        })
    }
    
    /**
     Test get time estimates.
     */
    func testGetTimeEstimates() {
        stub(isHost("sandbox-api.uber.com")) { _ in
            return OHHTTPStubsResponse(fileAtPath:OHPathForFile("getTimeEstimates.json", self.dynamicType)!, statusCode:200, headers:nil)
        }
        
        let expectation = expectationWithDescription("get time estimates")
        let location = CLLocation(latitude: pickupLat, longitude: pickupLong)
        client.fetchTimeEstimates(pickupLocation: location, completion:{ timeEstimates, response in
            
            XCTAssertEqual(timeEstimates.count, 4)
            XCTAssertEqual(timeEstimates[0].estimate, 410)
            XCTAssertEqual(timeEstimates[1].estimate, 535)
            XCTAssertEqual(timeEstimates[2].estimate, 294)
            XCTAssertEqual(timeEstimates[3].estimate, 288)
            
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(timeout, handler:{ error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        })
    }
    
    /**
     Test get price estimates.
     */
    func testGetPriceEstimates() {
        stub(isHost("sandbox-api.uber.com")) { _ in
            return OHHTTPStubsResponse(fileAtPath:OHPathForFile("getPriceEstimates.json", self.dynamicType)!, statusCode:200, headers:nil)
        }
        
        let expectation = expectationWithDescription("get price estimates")
        let pickupLocation = CLLocation(latitude: pickupLat, longitude: pickupLong)
        let dropoffLocation = CLLocation(latitude: dropoffLat, longitude: dropoffLong)
        client.fetchPriceEstimates(pickupLocation: pickupLocation, dropoffLocation: dropoffLocation, completion:{ priceEstimates, response in
            
            XCTAssertEqual(priceEstimates.count, 4)
            XCTAssertEqual(priceEstimates[0].estimate, "$23-29")
            XCTAssertEqual(priceEstimates[1].estimate, "$36-44")
            XCTAssertEqual(priceEstimates[2].estimate, "Metered")
            XCTAssertEqual(priceEstimates[3].estimate, "$15")
            
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(timeout, handler:{ error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        })
    }
    
    /**
     Test get trip history.
     */
    func testGetHistory() {
        stub(isHost("sandbox-api.uber.com")) { _ in
            return OHHTTPStubsResponse(fileAtPath:OHPathForFile("getHistory.json", self.dynamicType)!, statusCode:200, headers:nil)
        }
        
        let expectation = expectationWithDescription("get user history")
    
        client.fetchTripHistory(completion: { userActivity, response in
            XCTAssertNotNil(userActivity)
            XCTAssertNotNil(userActivity!.history)
            XCTAssertEqual(userActivity!.history!.count, 1)
            XCTAssertEqual(userActivity!.history![0].status, RideStatus.Completed)
            
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(timeout, handler:{ error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        })
    }
    
    /**
     Test get user profile.
     */
    func testGetUserProfile() {
        stub(isHost("sandbox-api.uber.com")) { _ in
            return OHHTTPStubsResponse(fileAtPath: OHPathForFile("getMe.json", self.dynamicType)!, statusCode: 200, headers: nil)
        }
        
        let expectation = expectationWithDescription("get user profile")
        
        client.fetchUserProfile({ profile, error in
            XCTAssertNotNil(profile)
            XCTAssertEqual(profile!.firstName, "Uber")
            XCTAssertEqual(profile!.lastName, "Developer")
            
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(timeout, handler:{ error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        })
    }
    
    /**
     Test post ride request.
     */
    func testMakeRideRequest() {
        stub(isHost("sandbox-api.uber.com")) { _ in
            return OHHTTPStubsResponse(fileAtPath: OHPathForFile("postRequests.json", self.dynamicType)!, statusCode: 200, headers: nil)
        }
        
        let expectation = expectationWithDescription("make ride request")
        
        let rideParameters = RideParametersBuilder().setPickupPlaceID("home").build()
        client.requestRide(rideParameters, completion: { ride, response in
            XCTAssertNotNil(ride)
            XCTAssertEqual(ride!.status, RideStatus.Processing)
            XCTAssertEqual(ride!.requestID, "852b8fdd-4369-4659-9628-e122662ad257")
            XCTAssertEqual(ride!.eta, 5)
            
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(timeout, handler:{ error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        })
    }
    
    /**
     Test get current trip.
     */
    func testGetCurrentRide() {
        stub(isHost("sandbox-api.uber.com")) { _ in
            return OHHTTPStubsResponse(fileAtPath: OHPathForFile("getRequest.json", self.dynamicType)!, statusCode: 200, headers: nil)
        }
        
        let expectation = expectationWithDescription("get current ride")
        
        client.fetchCurrentRide({ ride, response in
            XCTAssertNotNil(ride)
            XCTAssertEqual(ride!.requestID, "17cb78a7-b672-4d34-a288-a6c6e44d5315")
            XCTAssertEqual(ride!.status, RideStatus.Accepted)
            
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(timeout, handler:{ error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        })
    }
    
    /**
     Test get ride by ID.
     */
    func testGetRideByID() {
        stub(isHost("sandbox-api.uber.com")) { _ in
            return OHHTTPStubsResponse(fileAtPath: OHPathForFile("getRequest.json", self.dynamicType)!, statusCode: 200, headers: nil)
        }
        
        let expectation = expectationWithDescription("get ride by ID")
        
        client.fetchRideDetails("someID", completion: { ride, response in
            XCTAssertNotNil(ride)
            XCTAssertEqual(ride!.requestID, "17cb78a7-b672-4d34-a288-a6c6e44d5315")
            XCTAssertEqual(ride!.status, RideStatus.Accepted)
            
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(timeout, handler:{ error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        })
    }
    
    /**
     Test get request estimate.
     */
    func testGetRequestEstimate() {
        stub(isHost("sandbox-api.uber.com")) { _ in
            return OHHTTPStubsResponse(fileAtPath: OHPathForFile("requestEstimate.json", self.dynamicType)!, statusCode: 200, headers: nil)
        }
        
        let expectation = expectationWithDescription("get request estimate")
        let rideParams = RideParametersBuilder().setPickupPlaceID("home").build()
        
        client.fetchRideRequestEstimate(rideParams, completion:{ estimate, error in
            XCTAssertNotNil(estimate)
            XCTAssertEqual(estimate!.pickupEstimate, 2)
            
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(timeout, handler:{ error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        })
    }
    
    func testGetPlace() {
        stub(isHost("sandbox-api.uber.com")) { _ in
            return OHHTTPStubsResponse(fileAtPath: OHPathForFile("place.json", self.dynamicType)!, statusCode: 200, headers: nil)
        }
        
        let expectation = expectationWithDescription("get place")
        let testPlace = Place.Home
        
        client.fetchPlace(testPlace, completion: { place, response in
            guard let place = place else {
                XCTAssert(false)
                return
            }
            
            XCTAssertEqual(place.address, "685 Market St, San Francisco, CA 94103, USA")
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(timeout, handler:{ error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        })
    }
    
    /**
     Test getting a 404 response when getting place.
     */
    func testGetPlace404Response() {
        stub(isHost("sandbox-api.uber.com")) { _ in
            let obj = ["code":"unknown_place_id", "title": "The given place id does not exist"]
            return OHHTTPStubsResponse(JSONObject: obj, statusCode: 404, headers: nil)
        }
        
        let expectation = expectationWithDescription("get place not found error")
        let testPlace = "gym"
        
        client.fetchPlace(testPlace, completion: { place, response in
            XCTAssertNil(place)
            
            guard let error = response.error else {
                XCTAssert(false)
                return
            }
            
            XCTAssertEqual(error.status, 404)
            XCTAssertEqual(error.code, "unknown_place_id")
            XCTAssertEqual(error.title, "The given place id does not exist")
            
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(timeout, handler:{ error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        })
    }
    
    /**
     Test getting a 401 response when getting place
     */
    func testGetPlace401Response() {
        stub(isHost("sandbox-api.uber.com")) { _ in
            let obj = ["code":"unauthorized", "title": "The supplied bearer token is invalid."]
            return OHHTTPStubsResponse(JSONObject: obj, statusCode: 401, headers: nil)
        }
        
        let expectation = expectationWithDescription("get place not found error")
        let testPlace = Place.Home
        
        client.fetchPlace(testPlace, completion: { place, response in
            XCTAssertNil(place)
            
            guard let error = response.error else {
                XCTAssert(false)
                return
            }
            
            XCTAssertEqual(error.status, 401)
            XCTAssertEqual(error.code, "unauthorized")
            XCTAssertEqual(error.title, "The supplied bearer token is invalid.")
            
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(timeout, handler:{ error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        })
    }
    
    func testUpdateRideDetailsSuccess() {
        stub(isHost("sandbox-api.uber.com")) { _ in
            return OHHTTPStubsResponse(JSONObject: [], statusCode: 204, headers: nil)
        }
        
        let expectation = expectationWithDescription("update ride")
        let params = RideParametersBuilder().setDropoffPlaceID(Place.Work).build()
        client.updateRideDetails("requestID1234", rideParameters: params, completion: { response in
            XCTAssertNil(response.error)
            XCTAssertEqual(response.statusCode, 204)
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(timeout, handler: { error in
            XCTAssertNil(error)
        })
    }
    
    func testUpdateRideDetailsUnauthorized() {
        stub(isHost("sandbox-api.uber.com")) { _ in
            return OHHTTPStubsResponse(JSONObject: ["code":"unauthorized", "title":"Invalid OAuth 2.0 credentials provided."], statusCode: 401, headers: nil)
        }
        
        let expectation = expectationWithDescription("update ride")
        let params = RideParametersBuilder().setDropoffPlaceID(Place.Work).build()
        client.updateRideDetails("requestID1234", rideParameters: params, completion: { response in
            guard let error = response.error else {
                XCTAssert(false)
                return
            }
            
            XCTAssertEqual(response.statusCode, 401)
            XCTAssertEqual(error.code, "unauthorized")
            XCTAssertEqual(error.title, "Invalid OAuth 2.0 credentials provided.")
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(timeout, handler: { error in
            XCTAssertNil(error)
        })
    }
    
    func testUpdateRideDetailsNotFound() {
        stub(isHost("sandbox-api.uber.com")) { _ in
            return OHHTTPStubsResponse(JSONObject: ["code":"not_found", "title":"The provided request ID doesn't exist."], statusCode: 404, headers: nil)
        }
        
        let expectation = expectationWithDescription("update ride")
        let params = RideParametersBuilder().setDropoffPlaceID(Place.Work).build()
        client.updateRideDetails("requestID1234", rideParameters: params, completion: { response in
            guard let error = response.error else {
                XCTAssert(false)
                return
            }
            
            XCTAssertEqual(response.statusCode, 404)
            XCTAssertEqual(error.code, "not_found")
            XCTAssertEqual(error.title, "The provided request ID doesn't exist.")
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(timeout, handler: { error in
            XCTAssertNil(error)
        })
    }
    
    func testUpdateRideDetailsValidationFailed() {
        stub(isHost("sandbox-api.uber.com")) { _ in
            return OHHTTPStubsResponse(JSONObject: ["code":"validation_failed", "title": "The input failed invalidation."], statusCode: 422, headers: nil)
        }
        
        let expectation = expectationWithDescription("update ride")
        let params = RideParametersBuilder().setDropoffPlaceID(Place.Work).build()
        client.updateRideDetails("requestID1234", rideParameters: params, completion: { response in
            guard let error = response.error else {
                XCTAssert(false)
                return
            }
            
            XCTAssertEqual(response.statusCode, 422)
            XCTAssertEqual(error.code, "validation_failed")
            XCTAssertEqual(error.title, "The input failed invalidation.")
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(timeout, handler: { error in
            XCTAssertNil(error)
        })
    }
    
    func testUpdateCurrentRide() {
        stub(isHost("sandbox-api.uber.com")) { _ in
            return OHHTTPStubsResponse(JSONObject: [], statusCode: 204, headers: nil)
        }
        
        let expectation = expectationWithDescription("update ride")
        let params = RideParametersBuilder().setDropoffPlaceID(Place.Work).build()
        client.updateCurrentRide(params, completion: { response in
            XCTAssertNil(response.error)
            XCTAssertEqual(response.statusCode, 204)
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(timeout, handler: { error in
            XCTAssertNil(error)
        })
    }
    
    func testUpdateCurrentRideUnauthorized() {
        stub(isHost("sandbox-api.uber.com")) { _ in
            return OHHTTPStubsResponse(JSONObject: ["code":"unauthorized", "title":"Invalid OAuth 2.0 credentials provided."], statusCode: 401, headers: nil)
        }
        
        let expectation = expectationWithDescription("update ride")
        let params = RideParametersBuilder().setDropoffPlaceID(Place.Work).build()
        client.updateCurrentRide(params, completion: { response in
            guard let error = response.error else {
                XCTAssert(false)
                return
            }
            
            XCTAssertEqual(response.statusCode, 401)
            XCTAssertEqual(error.code, "unauthorized")
            XCTAssertEqual(error.title, "Invalid OAuth 2.0 credentials provided.")
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(timeout, handler: { error in
            XCTAssertNil(error)
        })
    }
    
    func testUpdateCurrentRideForbidden() {
        stub(isHost("sandbox-api.uber.com")) { _ in
            return OHHTTPStubsResponse(JSONObject: ["code":"forbidden", "title":"Forbidden."], statusCode: 403, headers: nil)
        }
        
        let expectation = expectationWithDescription("update ride")
        let params = RideParametersBuilder().setDropoffPlaceID(Place.Work).build()
        client.updateCurrentRide(params, completion: { response in
            guard let error = response.error else {
                XCTAssert(false)
                return
            }
            
            XCTAssertEqual(response.statusCode, 403)
            XCTAssertEqual(error.code, "forbidden")
            XCTAssertEqual(error.title, "Forbidden.")
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(timeout, handler: { error in
            XCTAssertNil(error)
        })
    }
    
    func testUpdateCurrentRideNoCurrentTrip() {
        stub(isHost("sandbox-api.uber.com")) { _ in
            return OHHTTPStubsResponse(JSONObject: ["code":"no_current_trip", "title":"User is not currently on a trip."], statusCode: 404, headers: nil)
        }
        
        let expectation = expectationWithDescription("update ride")
        let params = RideParametersBuilder().setDropoffPlaceID(Place.Work).build()
        client.updateCurrentRide(params, completion: { response in
            guard let error = response.error else {
                XCTAssert(false)
                return
            }
            
            XCTAssertEqual(response.statusCode, 404)
            XCTAssertEqual(error.code, "no_current_trip")
            XCTAssertEqual(error.title, "User is not currently on a trip.")
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(timeout, handler: { error in
            XCTAssertNil(error)
        })
    }
    
    func testUpdateCurrentRideValidationFailed() {
        stub(isHost("sandbox-api.uber.com")) { _ in
            return OHHTTPStubsResponse(JSONObject: ["code":"validation_failed", "title":"The input failed invalidation."], statusCode: 422, headers: nil)
        }
        
        let expectation = expectationWithDescription("update ride")
        let params = RideParametersBuilder().setDropoffPlaceID(Place.Work).build()
        client.updateCurrentRide(params, completion: { response in
            guard let error = response.error else {
                XCTAssert(false)
                return
            }
            
            XCTAssertEqual(response.statusCode, 422)
            XCTAssertEqual(error.code, "validation_failed")
            XCTAssertEqual(error.title, "The input failed invalidation.")
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(timeout, handler: { error in
            XCTAssertNil(error)
        })
    }
    
    func testCancelRideByID() {
        stub(isHost("sandbox-api.uber.com")) { _ in
            return OHHTTPStubsResponse(JSONObject: [], statusCode: 204, headers: nil)
        }
        
        let expectation = expectationWithDescription("delete ride")
        client.cancelRide("requestID1234", completion: { response in
            XCTAssertNil(response.error)
            XCTAssertEqual(response.statusCode, 204)
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(timeout, handler: { error in
            XCTAssertNil(error)
        })
    }
    
    func testCancelCurrentRide() {
        stub(isHost("sandbox-api.uber.com")) { _ in
            return OHHTTPStubsResponse(JSONObject: [], statusCode: 204, headers: nil)
        }
        
        let expectation = expectationWithDescription("delete ride")
        client.cancelCurrentRide({ response in
            XCTAssertNil(response.error)
            XCTAssertEqual(response.statusCode, 204)
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(timeout, handler: { error in
            XCTAssertNil(error)
        })
    }
    
    func testCancelCurrentRideUnauthorized() {
        stub(isHost("sandbox-api.uber.com")) { _ in
            return OHHTTPStubsResponse(JSONObject: ["code":"unauthorized", "title":"Invalid OAuth 2.0 Credentials provided."], statusCode: 401, headers: nil)
        }
        
        let expectation = expectationWithDescription("update ride")
        client.cancelCurrentRide({ response in
            guard let error = response.error else {
                XCTAssert(false)
                return
            }
            
            XCTAssertEqual(response.statusCode, 401)
            XCTAssertEqual(error.code, "unauthorized")
            XCTAssertEqual(error.title, "Invalid OAuth 2.0 Credentials provided.")
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(timeout, handler: { error in
            XCTAssertNil(error)
        })
    }
    
    func testCancelCurrentRideForbidden() {
        stub(isHost("sandbox-api.uber.com")) { _ in
            return OHHTTPStubsResponse(JSONObject: ["code":"forbidden", "title":"Forbidden"], statusCode: 403, headers: nil)
        }
        
        let expectation = expectationWithDescription("update ride")
        client.cancelCurrentRide({ response in
            guard let error = response.error else {
                XCTAssert(false)
                return
            }
            
            XCTAssertEqual(response.statusCode, 403)
            XCTAssertEqual(error.code, "forbidden")
            XCTAssertEqual(error.title, "Forbidden")
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(timeout, handler: { error in
            XCTAssertNil(error)
        })
    }
    
    func testCancelCurrentRideNoCurrentTrip() {
        stub(isHost("sandbox-api.uber.com")) { _ in
            return OHHTTPStubsResponse(JSONObject: ["code":"no_current_trip", "title":"User is not currently on a trip."], statusCode: 404, headers: nil)
        }
        
        let expectation = expectationWithDescription("update ride")
        client.cancelCurrentRide({ response in
            guard let error = response.error else {
                XCTAssert(false)
                return
            }
            
            XCTAssertEqual(response.statusCode, 404)
            XCTAssertEqual(error.code, "no_current_trip")
            XCTAssertEqual(error.title, "User is not currently on a trip.")
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(timeout, handler: { error in
            XCTAssertNil(error)
        })
    }
    
    /**
     Test get payment methods (including last used).
     */
    func testGetPaymentMethods() {
        stub(isHost("sandbox-api.uber.com")) { _ in
            return OHHTTPStubsResponse(fileAtPath: OHPathForFile("getPaymentMethods.json", self.dynamicType)!, statusCode: 200, headers: nil)
        }
        
        let expectation = expectationWithDescription("get payment methods")
        client.fetchPaymentMethods({ methods, lastUsed, response in
            guard let lastUsed = lastUsed else {
                XCTAssert(false)
                return
            }
            
            XCTAssertEqual(methods.count, 4)
            XCTAssertEqual(lastUsed, methods[3])
            
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(timeout, handler:{ error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        })
    }
    
    func testGetRideReceipt() {
        stub(isHost("sandbox-api.uber.com")) { _ in
            return OHHTTPStubsResponse(fileAtPath: OHPathForFile("rideReceipt.json", self.dynamicType)!, statusCode: 200, headers: nil)
        }
        
        let expectation = expectationWithDescription("ride receipt")
        client.fetchRideReceipt("requestID1234", completion: { receipt, response in
            guard let receipt = receipt else {
                XCTAssert(false)
                return
            }
            
            XCTAssertEqual(receipt.requestID, "b5512127-a134-4bf4-b1ba-fe9f48f56d9d")
            
            XCTAssertEqual(response.statusCode, 200)
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(timeout, handler: { error in
            XCTAssertNil(error)
        })
    }
    
    func testGetRideMap() {
        stub(isHost("sandbox-api.uber.com")) { _ in
            return OHHTTPStubsResponse(fileAtPath: OHPathForFile("rideMap.json", self.dynamicType)!, statusCode: 200, headers: nil)
        }
        
        let expectation = expectationWithDescription("ride map")
        client.fetchRideMap("requestID1234", completion: { map, response in
            guard let map = map else {
                XCTAssert(false)
                return
            }
            
            XCTAssertEqual(map.requestID, "b5512127-a134-4bf4-b1ba-fe9f48f56d9d")
            XCTAssertEqual(map.path, "https://trip.uber.com/abc123")
            
            XCTAssertEqual(response.statusCode, 200)
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(timeout, handler: { error in
            XCTAssertNil(error)
        })
    }
    
    func testGetRideMapNotFound() {
        stub(isHost("sandbox-api.uber.com")) { _ in
            return OHHTTPStubsResponse(JSONObject: ["code":"no_current_trip", "title":"User is not currently on a trip."], statusCode: 404, headers: nil)
        }
        
        let expectation = expectationWithDescription("ride map")
        client.fetchRideMap("requestID1234", completion: { map, response in
            XCTAssertNil(map)
            
            guard let error = response.error else {
                XCTAssert(false)
                return
            }
            
            XCTAssertEqual(error.code, "no_current_trip")
            XCTAssertEqual(error.title, "User is not currently on a trip.")
            
            XCTAssertEqual(response.statusCode, 404)
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(timeout, handler: { error in
            XCTAssertNil(error)
        })
    }
    
    func testRefreshToken() {
        stub(isHost("login.uber.com")) { _ in
            return OHHTTPStubsResponse(fileAtPath: OHPathForFile("refresh.json", self.dynamicType)!, statusCode: 200, headers: nil)
        }
        let refreshToken = "thisIsRefresh"
        let expectedScopeString = "request all_trips profile ride_widgets history places history_lite"
        let expectedScopes = expectedScopeString.toRidesScopesArray()
        let expectedScopeSet = Set(expectedScopes)
        
        let expectation = expectationWithDescription("Refresh token completion")
        client.refreshAccessToken(refreshToken, completion: { accessToken, response in
            guard let accessToken = accessToken, let scopes = accessToken.grantedScopes else {
                XCTAssert(false)
                return
            }
            
            XCTAssertEqual(accessToken.tokenString, "Access999Token")
            XCTAssertEqual(accessToken.refreshToken, "888RefreshToken")
            
            let testScopeSet = Set(scopes)
            XCTAssertEqual(testScopeSet, expectedScopeSet)
            
            XCTAssertEqual(response.statusCode, 200)
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(timeout, handler: { error in
            XCTAssertNil(error)
        })
    }
    
    func testRefreshTokenInvalid() {
        stub(isHost("login.uber.com")) { _ in
            return OHHTTPStubsResponse(JSONObject: ["error":"invalid_refresh_token"], statusCode: 400, headers: nil)
        }
        let refreshToken = "thisIsRefresh"

        let expectation = expectationWithDescription("Refresh token completion")
        client.refreshAccessToken(refreshToken, completion: { accessToken, response in
            XCTAssertNil(accessToken)
            
            guard let error = response.error else {
                XCTFail()
                return
            }
            XCTAssertEqual(error.title, "invalid_refresh_token")
            
            XCTAssertEqual(response.statusCode, 400)
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(timeout, handler: { error in
            XCTAssertNil(error)
        })
    }
    
    /**
     Test to check getting the access token when using the default settings
     and the token exists
     */
    func testGetAccessTokenSuccess_defaultId_defaultGroup() {
        let tokenData = [ "access_token" : "testAccessToken" ]
        guard let token = AccessToken(JSON: tokenData) else {
            XCTAssert(false)
            return
        }

        let keychainHelper = KeychainWrapper()
        
        let tokenKey = Configuration.getDefaultAccessTokenIdentifier()
        let tokenGroup = Configuration.getDefaultKeychainAccessGroup()
        
        keychainHelper.setAccessGroup(tokenGroup)
        XCTAssertTrue(keychainHelper.setObject(token, key: tokenKey))
        defer {
            XCTAssertTrue(keychainHelper.deleteObjectForKey(tokenKey))
        }
        
        let ridesClient = RidesClient()
        guard let accessToken = ridesClient.fetchAccessToken() else {
            XCTFail("Unable to fetch Access Token")
            return
        }
        XCTAssertEqual(accessToken.tokenString, token.tokenString)
    }
    
    /**
     Test to check getting the access token when using the default settings
     and the token doesn't exist
     */
    func testGetAccessTokenFail_defaultId_defaultGroup() {
        let ridesClient = RidesClient()
        let accessToken = ridesClient.fetchAccessToken()
        XCTAssertNil(accessToken)
    }
    
    /**
     Test to check getting the access token when using a custom ID and default group
     and the token exists
     */
    func testGetAccessTokenSuccess_customId_defaultGroup() {
        let tokenData = [ "access_token" : "testAccessToken" ]
        guard let token = AccessToken(JSON: tokenData) else {
            XCTAssert(false)
            return
        }
        let keychainHelper = KeychainWrapper()
        
        let tokenKey = "newTokenKey"
        let tokenGroup = Configuration.getDefaultKeychainAccessGroup()
        
        keychainHelper.setAccessGroup(tokenGroup)
        XCTAssertTrue(keychainHelper.setObject(token, key: tokenKey))
        defer {
            XCTAssertTrue(keychainHelper.deleteObjectForKey(tokenKey))
        }
        
        let ridesClient = RidesClient(accessTokenIdentifier: tokenKey)
        guard let accessToken = ridesClient.fetchAccessToken() else {
            XCTFail("Unable to fetch Access Token")
            return
        }
        XCTAssertEqual(accessToken.tokenString, token.tokenString)
    }
}
