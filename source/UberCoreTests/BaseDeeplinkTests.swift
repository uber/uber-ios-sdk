//
//  BaseDeeplinkTests.swift
//  UberRides
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

@testable import UberCore

class BaseDeeplinkTests: XCTestCase {
    
    private var versionNumber: String?
    
    override func setUp() {
        super.setUp()
        Configuration.plistName = "testInfo"
        Configuration.restoreDefaults()
        versionNumber = Bundle(for: BaseDeeplink.self).object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
    
    override func tearDown() {
        Configuration.restoreDefaults()
        super.tearDown()
    }
    
    func testInit() {
        let testScheme = "testScheme"
        let testDomain = "testDomain"
        let testPath = "/testPath"
        let testQueryItems = [URLQueryItem(name: "test", value: "testing")]
        
        var urlComponents = URLComponents()
        urlComponents.scheme = testScheme
        urlComponents.host = testDomain
        urlComponents.path = testPath
        urlComponents.queryItems = testQueryItems
        let expectedURL = urlComponents.url

        guard let baseDeeplink = BaseDeeplink(scheme: testScheme, host: testDomain, path: testPath, queryItems: testQueryItems) else {
            XCTFail()
            return
        }

        XCTAssertEqual(baseDeeplink.url, expectedURL)
    }

    func testUberSchemeResultsInFallbacks() {
        guard let deeplink = BaseDeeplink(scheme: "uber", host: "", path: "", queryItems: nil) else {
            XCTFail()
            return
        }
        XCTAssertEqual(deeplink.fallbackURLs.count, 2)
        XCTAssertEqual(deeplink.fallbackURLs[0].scheme, "uber-enterprise")
        XCTAssertEqual(deeplink.fallbackURLs[1].scheme, "uber-nightly")
    }

    func testNonUberSchemeResultsInNoFallbacks() {
        guard let deeplink = BaseDeeplink(scheme: "uberauth", host: "", path: "", queryItems: nil) else {
            XCTFail()
            return
        }
        XCTAssertEqual(deeplink.fallbackURLs.count, 0)
    }
}



