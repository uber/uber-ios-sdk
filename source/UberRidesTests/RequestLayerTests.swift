//
//  RequestLayerTests.swift
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
import OHHTTPStubsSwift
import UberCore
@testable import UberRides

class RequestLayerTests: XCTestCase {
    var client: RidesClient!
    var headers: [AnyHashable: Any]!
    let timeout: Double = 10
    
    override func setUp() {
        super.setUp()
        Configuration.plistName = "testInfo"
        Configuration.restoreDefaults()
        Configuration.shared.isSandbox = true
        headers = ["Content-Type": "application/json"]
        client = RidesClient()
    }
    
    override func tearDown() {
        HTTPStubs.removeAllStubs()
        Configuration.restoreDefaults()
        super.tearDown()
    }
    
    /**
     Test 200 success response
     */
    func test200Response() {
        stub(condition: isHost("sandbox-api.uber.com")) { _ in
            return HTTPStubsResponse(fileAtPath:OHPathForFile("getProductID.json", type(of: self))!, statusCode:200, headers:self.headers)
        }
        
        let expectation = self.expectation(description: "200 success response")
        let endpoint = Products.getProduct(productID: productID)
        guard let request = Request(session: client.session, endpoint: endpoint) else {
            XCTFail("Unable to create request")
            return
        }
        request.execute({ response in
            XCTAssertEqual(response.statusCode, 200)
            XCTAssertNil(response.error)
            
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: timeout, handler: { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
            request.cancelTasks()
        })
    }
     
    /**
     Test 401 authorization error response.
     */
    func test401Error() {
        let message = "Invalid OAuth 2.0 credentials provided."
        let code = "unauthorized"
        
        stub(condition: isHost("sandbox-api.uber.com")) { _ in
            let json = ["message": message, "code": code]
            return HTTPStubsResponse(jsonObject: json, statusCode: 401, headers: self.headers)
        }
        
        let expectation = self.expectation(description: "401 error response")
        let endpoint = Products.getProduct(productID: productID)
        guard let request = Request(session: client.session, endpoint: endpoint) else {
            XCTFail("Unable to create request")
            return
        }
        request.execute({ response in
            XCTAssertEqual(response.statusCode, 401)
            XCTAssertNotNil(response.error)
            XCTAssertTrue(response.error is UberClientError)
            XCTAssertEqual(response.error!.title, message)
            XCTAssertEqual(response.error!.code, code)
            XCTAssertNil(response.error!.meta)
            
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: timeout, handler: { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
            request.cancelTasks()
        })
    }
    
    /**
     Test 409 surge error response.
     */
    func test409Error() {
        stub(condition: isHost("sandbox-api.uber.com")) { _ in
            let json = ["meta": ["surge_confirmation": ["href": "api.uber.com/v1/surge-confirmations/abc", "surge_confirmation_id": "abc"]]]
            return HTTPStubsResponse(jsonObject: json, statusCode: 409, headers: self.headers)
        }
        
        let expectation = self.expectation(description: "409 error response")
        let endpoint = Products.getProduct(productID: productID)
        guard let request = Request(session: client.session, endpoint: endpoint) else {
            XCTFail("Unable to create request")
            return
        }
        request.execute({ response in
            XCTAssertEqual(response.statusCode, 409)
            XCTAssertNotNil(response.error)
            XCTAssertTrue(response.error is UberClientError)
            XCTAssertNotNil(response.error!.meta)
            
                let meta = response.error!.meta! as! [String: [String: String]]
            XCTAssertEqual(meta["surge_confirmation"]!["href"], "api.uber.com/v1/surge-confirmations/abc")
            XCTAssertEqual(meta["surge_confirmation"]!["surge_confirmation_id"], "abc")
            
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: timeout, handler: { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
            request.cancelTasks()
        })
    }
    
    /**
     Test 422 lat/long validation error response.
     */
    func test422ValidationError() {
        let message = "Invalid request."
        let code = "validation_failed"
        let fields = ["latitude": ["Must be between -90.0 and 90.0"], "longitude": ["Must be between -90.0 and 90.0"]]
        
        stub(condition: isHost("sandbox-api.uber.com")) { _ in
            let json = ["message": message, "code": code, "fields": fields] as [String : Any]
            return HTTPStubsResponse(jsonObject: json, statusCode: 422, headers: self.headers)
        }
        
        let expectation = self.expectation(description: "422 error response")
        let endpoint = Products.getProduct(productID: productID)
        guard let request = Request(session: client.session, endpoint: endpoint) else {
            XCTFail("Unable to create request")
            return
        }
        request.execute({ response in
            XCTAssertEqual(response.statusCode, 422)
            XCTAssertNotNil(response.error)
            XCTAssertTrue(response.error is UberClientError)
            XCTAssertEqual(response.error!.title, message)
            XCTAssertEqual(response.error!.code, code)
            
            let fields = response.error!.meta! as! [String: [String]]
            XCTAssertEqual(fields.count, 2)
            XCTAssertEqual(fields["latitude"]![0], "Must be between -90.0 and 90.0")
            XCTAssertEqual(fields["longitude"]![0], "Must be between -90.0 and 90.0")
            
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: timeout, handler: { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
            request.cancelTasks()
        })
    }
    
    /**
     Test 422 distance exceeded error response.
     */
    func test422DistanceExceededError() {
        let message = "Distance between two points exceeds 100 miles."
        let code = "distance_exceeded"
        let fields = ["start_latitude": [message], "end_latitude": [message], "start_longitude": [message], "end_longitude": [message]]
        
        stub(condition: isHost("sandbox-api.uber.com")) { _ in
            let json = ["message": message, "code": code, "fields": fields] as [String : Any]
            return HTTPStubsResponse(jsonObject: json, statusCode: 422, headers: self.headers)
        }
        
        let expectation = self.expectation(description: "422 error response")
        let endpoint = Products.getProduct(productID: productID)
        guard let request = Request(session: client.session, endpoint: endpoint) else {
            XCTFail("Unable to create request")
            return
        }
        request.execute({ response in
            XCTAssertEqual(response.statusCode, 422)
            XCTAssertNotNil(response.error)
            XCTAssertTrue(response.error is UberClientError)
            XCTAssertEqual(response.error!.title, message)
            XCTAssertEqual(response.error!.code, code)
            
            let fields = response.error!.meta! as! [String: [String]]
            XCTAssertEqual(fields.count, 4)
            XCTAssertEqual(fields["start_latitude"]![0], message)
            XCTAssertEqual(fields["start_longitude"]![0], message)
            XCTAssertEqual(fields["end_latitude"]![0], message)
            XCTAssertEqual(fields["end_longitude"]![0], message)
            
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: timeout, handler: { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
            request.cancelTasks()
        })
    }
    
    /**
     Test 422 same pickup and dropoff error response.
     */
    func test422SamePickupDropoffError() {
        let code = "same_pickup_dropoff"
        let message = "Pickup and Dropoff can't be the same."
        
        stub(condition: isHost("sandbox-api.uber.com")) { _ in
            let json = ["meta": [], "errors": [["status": 422, "code": code, "title": message]]]
            return HTTPStubsResponse(jsonObject: json, statusCode: 409, headers: self.headers)
        }
        
        let expectation = self.expectation(description: "422 error response")
        let endpoint = Products.getProduct(productID: productID)
        guard let request = Request(session: client.session, endpoint: endpoint) else {
            XCTFail("Unable to create request")
            return
        }
        request.execute({ response in
            XCTAssertEqual(response.statusCode, 409)
            XCTAssertNotNil(response.error)
            XCTAssertTrue(response.error is UberClientError)
            XCTAssertNil(response.error!.meta)
            XCTAssertEqual(response.error!.errors!.count, 1)
            
            let error = response.error!.errors![0]
            XCTAssertEqual(error.status, 422)
            XCTAssertEqual(error.code, code)
            XCTAssertEqual(error.title, message)
            
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: timeout, handler: { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
            request.cancelTasks()
        })
    }
    
    /**
     Test 500 internal server error response.
     */
    func test500Error() {
        let message = "Unexpected internal server error occurred."
        let code = "internal_server_error"
        
        stub(condition: isHost("sandbox-api.uber.com")) { _ in
            let json = ["message": message, "code": code]
            return HTTPStubsResponse(jsonObject: json, statusCode: 500, headers: self.headers)
        }
        
        let expectation = self.expectation(description: "500 error response")
        let endpoint = Products.getProduct(productID: productID)
        guard let request = Request(session: client.session, endpoint: endpoint) else {
            XCTFail("Unable to create request")
            return
        }
        request.execute({ response in
            XCTAssertEqual(response.statusCode, 500)
            XCTAssertNotNil(response.error)
            XCTAssertTrue(response.error is UberServerError)
            XCTAssertEqual(response.error!.title, message)
            XCTAssertEqual(response.error!.code, code)
            XCTAssertNil(response.error!.meta)
            
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: timeout, handler: { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
            request.cancelTasks()
        })
    }
    
    /**
     Test 503 service unavailable error response.
     */
    func test503Error() {
        let message = "Service temporarily unavailable."
        let code = "service_unavailable"
        
        stub(condition: isHost("sandbox-api.uber.com")) { _ in
            let json = ["message": message, "code": code]
            return HTTPStubsResponse(jsonObject: json, statusCode: 503, headers: self.headers)
        }
        
        let expectation = self.expectation(description: "503 error response")
        let endpoint = Products.getProduct(productID: productID)
        guard let request = Request(session: client.session, endpoint: endpoint) else {
            XCTFail("Unable to create request")
            return
        }
        request.execute({ response in
            XCTAssertEqual(response.statusCode, 503)
            XCTAssertNotNil(response.error)
            XCTAssertTrue(response.error is UberServerError)
            XCTAssertEqual(response.error!.title, message)
            XCTAssertEqual(response.error!.code, code)
            XCTAssertNil(response.error!.meta)
            
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: timeout, handler: { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
            request.cancelTasks()
        })
    }
    
    /**
    *  Test no network error response - unknown error.
    */
    func testNoNetworkError() {
        stub(condition: isHost("sandbox-api.uber.com")) { _ in
            let notConnectedError = NSError(domain: NSURLErrorDomain, code: Int(CFNetworkErrors.cfurlErrorNotConnectedToInternet.rawValue), userInfo: nil)
            return HTTPStubsResponse(error:notConnectedError)
        }
        
        let expectation = self.expectation(description: "No network error response")
        let endpoint = Products.getProduct(productID: productID)
        guard let request = Request(session: client.session, endpoint: endpoint) else {
            XCTFail("Unable to create request")
            return
        }
        request.execute({ response in
            XCTAssertEqual(response.statusCode, 0)
            XCTAssertNotNil(response.error)
            XCTAssertTrue(response.error is UberUnknownError)
            XCTAssertEqual(response.error!.title, NSURLErrorDomain)
            XCTAssertEqual(response.error!.status, Int(CFNetworkErrors.cfurlErrorNotConnectedToInternet.rawValue))
            XCTAssertNil(response.error!.meta)
            
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: timeout, handler: { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
            request.cancelTasks()
        })
    }
}
