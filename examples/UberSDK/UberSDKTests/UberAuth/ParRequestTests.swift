//
//  ParRequestTests.swift
//  UberSDKTests
//
//  Copyright © 2024 Uber Technologies, Inc. All rights reserved.
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


@testable import UberAuth
import XCTest

final class ParRequestTests: XCTestCase {

    func test_generatedUrl() {
        
        let prefillValues =  [
            "firstName": "test_first_name",
            "lastName": "test_last_name",
            "phone": "test_phone_number",
            "email": "test_email",
        ]
        
        let request = ParRequest(
            clientID: "test_client_id",
            prefill: prefillValues
        )
        
        let loginHintString = (try! JSONSerialization.data(withJSONObject: prefillValues)).base64EncodedString()
        
        let urlRequest = request.urlRequest(baseUrl: "https://auth.uber.com")!
        let url = urlRequest.url!
        
        XCTAssertEqual(url.host(), "auth.uber.com")
        XCTAssertEqual(url.scheme, "https")
        XCTAssertEqual(url.path(), "/oauth/v2/par")
        XCTAssertEqual(request.body?["login_hint"], loginHintString)
    }
    
}
