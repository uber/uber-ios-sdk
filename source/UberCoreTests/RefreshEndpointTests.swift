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
import OHHTTPStubsSwift
@testable import UberCore

class RefreshEndpointTests: XCTestCase {
    var session = URLSession.shared
    var headers: [AnyHashable: Any]!
    let timeout: Double = 1

    let clientID = Configuration.shared.clientID
    
    override func setUp() {
        super.setUp()
        Configuration.plistName = "testInfo"
        Configuration.restoreDefaults()
        Configuration.shared.isSandbox = true
        headers = ["Content-Type": "application/json"]
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
        stub(condition: isHost("login.uber.com")) { _ in
            return HTTPStubsResponse(fileAtPath:OHPathForFile("refresh.json", type(of: self))!, statusCode:200, headers:self.headers)
        }
        let refreshToken = "ThisIsRefresh"
        let expectation = self.expectation(description: "200 success response")
        let endpoint = OAuth.refresh(clientID: clientID, refreshToken: refreshToken)
        guard let request = Request(session: session, endpoint: endpoint) else {
            XCTFail("unable to create request")
            return
        }

        request.execute({ response in
            XCTAssertEqual(response.statusCode, 200)
            XCTAssertNil(response.error)

            expectation.fulfill()
        })

        XCTAssertEqual(request.urlRequest.httpMethod, "POST")

        guard let bodyData = request.urlRequest.httpBody, let dataString = String(data: bodyData, encoding: String.Encoding.utf8) else {
            XCTFail("Missing HTTP Body!")
            return
        }
        var components = URLComponents()
        components.query = dataString

        let expectedClientID = URLQueryItem(name: "client_id", value: clientID)
        let expectedRefreshToken = URLQueryItem(name: "refresh_token", value: refreshToken)

        guard let queryItems = components.queryItems else {
            XCTFail("Invalid HTTP Body!")
            return
        }

        XCTAssertTrue(queryItems.contains(expectedClientID))
        XCTAssertTrue(queryItems.contains(expectedRefreshToken))
        
        waitForExpectations(timeout: timeout, handler: { error in
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
        
        stub(condition: isHost("login.uber.com")) { _ in
            let json = ["error": error]
            return HTTPStubsResponse(jsonObject: json, statusCode: 400, headers: self.headers)
        }
        
        let refreshToken = "ThisIsRefresh"
        let expectation = self.expectation(description: "400 error response")
        let endpoint = OAuth.refresh(clientID: clientID, refreshToken: refreshToken)
        guard let request = Request(session: session, endpoint: endpoint) else {
            XCTFail("unable to create request")
            return
        }
        request.execute({ response in
            XCTAssertEqual(response.statusCode, 400)
            XCTAssertNotNil(response.error)
            XCTAssertEqual(response.error?.title, error)
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
