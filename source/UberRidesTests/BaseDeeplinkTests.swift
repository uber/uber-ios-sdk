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

@testable import UberRides

class BaseDeeplinkTests: XCTestCase {
    
    private var versionNumber: String?
    
    override func setUp() {
        super.setUp()
        Configuration.restoreDefaults()
        Configuration.plistName = "testInfo"
        Configuration.bundle = NSBundle(forClass: self.dynamicType)
        versionNumber = NSBundle(forClass: RideParameters.self).objectForInfoDictionaryKey("CFBundleShortVersionString") as? String
    }
    
    override func tearDown() {
        Configuration.restoreDefaults()
        super.tearDown()
    }
    
    func testInit() {
        let testScheme = "testScheme"
        let testDomain = "testDomain"
        let testPath = "/testPath"
        let testQueryItems = [NSURLQueryItem(name: "test", value: "testing")]
        
        let urlComponents = NSURLComponents()
        urlComponents.scheme = testScheme
        urlComponents.host = testDomain
        urlComponents.path = testPath
        urlComponents.queryItems = testQueryItems
        let expectedURL = urlComponents.URL
        
        guard let baseDeeplink = BaseDeeplink(scheme: testScheme, domain: testDomain, path: testPath, queryItems: testQueryItems) else {
            XCTFail()
            return
        }
        
        
        guard let queryItems = baseDeeplink.queryItems else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(baseDeeplink.scheme, testScheme)
        XCTAssertEqual(baseDeeplink.domain, testDomain)
        XCTAssertEqual(baseDeeplink.path, testPath)
        XCTAssertEqual(queryItems, testQueryItems)
        XCTAssertEqual(baseDeeplink.deeplinkURL, expectedURL)
    }
}



