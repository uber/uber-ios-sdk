//
//  RefreshEndpointTests.swift
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

import XCTest
import OHHTTPStubs
@testable import UberRides

class RefreshEndpointTests: XCTestCase {
    var client: RidesClient!
    var headers: [NSObject: AnyObject]!
    let timeout: Double = 1
    
    override func setUp() {
        super.setUp()
        Configuration.restoreDefaults()
        Configuration.plistName = "testInfo"
        Configuration.bundle = NSBundle(forClass: self.dynamicType)
        Configuration.setSandboxEnabled(true)
        headers = ["Content-Type": "application/json"]
        client = RidesClient()
    }
    
    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        Configuration.restoreDefaults()
        super.tearDown()
    }
    
    /**
     Test 200 success response
     */
    func test200Response() {
        stub(isHost("login.uber.com")) { _ in
            return OHHTTPStubsResponse(fileAtPath:OHPathForFile("refresh.json", self.dynamicType)!, statusCode:200, headers:self.headers)
        }
        let refreshToken = "ThisIsRefresh"
        let clientID = Configuration.getClientID()
        let expectation = expectationWithDescription("200 success response")
        let endpoint = OAuth.Refresh(clientID: clientID, refreshToken: refreshToken)
        let request = Request(session: client.session, endpoint: endpoint)

        request.execute({ response in
            XCTAssertEqual(response.statusCode, 200)
            XCTAssertNil(response.error)

            expectation.fulfill()
        })

        XCTAssertEqual(request.urlRequest.HTTPMethod, "POST")

        guard let bodyData = request.urlRequest.HTTPBody, dataString = String(data: bodyData, encoding: NSUTF8StringEncoding) else {
            XCTFail("Missing HTTP Body!")
            return
        }
        let components = NSURLComponents()
        components.query = dataString

        let expectedClientID = NSURLQueryItem(name: "client_id", value: clientID)
        let expectedRefreshToken = NSURLQueryItem(name: "refresh_token", value: refreshToken)

        guard let queryItems = components.queryItems else {
            XCTFail("Invalid HTTP Body!")
            return
        }

        XCTAssertTrue(queryItems.contains(expectedClientID))
        XCTAssertTrue(queryItems.contains(expectedRefreshToken))


        
        waitForExpectationsWithTimeout(timeout, handler: { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
            request.cancelTasks()
        })
    }
    
    /**
     Test 400 authorization error response.
     */
    func test400Error() {
        let error = "invalid_refresh_token"
        
        stub(isHost("login.uber.com")) { _ in
            let json = ["error": error]
            return OHHTTPStubsResponse(JSONObject: json, statusCode: 400, headers: self.headers)
        }
        
        let refreshToken = "ThisIsRefresh"
        let expectation = expectationWithDescription("400 error response")
        let endpoint = OAuth.Refresh(clientID: clientID, refreshToken: refreshToken)
        let request = Request(session: client.session, endpoint: endpoint)
        request.execute({ response in
            XCTAssertEqual(response.statusCode, 400)
            XCTAssertNotNil(response.error)
            XCTAssertEqual(response.error?.title, error)
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(timeout, handler: { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
            request.cancelTasks()
        })
    }
    
    /**
     Test 200 success response
     */
    func test200Response_inChina() {
        Configuration.setRegion(.China)
        stub(isHost("login.uber.com.cn")) { _ in
            return OHHTTPStubsResponse(fileAtPath:OHPathForFile("refresh.json", self.dynamicType)!, statusCode:200, headers:self.headers)
        }
        let refreshToken = "ThisIsRefresh"
        let expectation = expectationWithDescription("200 success response")
        let endpoint = OAuth.Refresh(clientID: clientID, refreshToken: refreshToken)
        let request = Request(session: client.session, endpoint: endpoint)
        request.execute({ response in
            XCTAssertEqual(response.statusCode, 200)
            XCTAssertNil(response.error)
            
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(timeout, handler: { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
            request.cancelTasks()
        })
    }
    
    /**
     Test 400 authorization error response.
     */
    func test400Error_inChina() {
        Configuration.setRegion(.China)
        let error = "invalid_refresh_token"
        
        stub(isHost("login.uber.com.cn")) { _ in
            let json = ["error": error]
            return OHHTTPStubsResponse(JSONObject: json, statusCode: 400, headers: self.headers)
        }
        
        let refreshToken = "ThisIsRefresh"
        let expectation = expectationWithDescription("400 error response")
        let endpoint = OAuth.Refresh(clientID: clientID, refreshToken: refreshToken)
        let request = Request(session: client.session, endpoint: endpoint)
        request.execute({ response in
            XCTAssertEqual(response.statusCode, 400)
            XCTAssertNotNil(response.error)
            XCTAssertEqual(response.error?.title, error)
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(timeout, handler: { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
            request.cancelTasks()
        })
    }
}
