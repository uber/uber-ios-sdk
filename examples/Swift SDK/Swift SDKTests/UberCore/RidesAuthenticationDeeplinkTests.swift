//
//  AuthenticationDeeplinkTests.swift
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

class RidesAuthenticationDeeplinkTests: XCTestCase {
    
    private var versionNumber: String?
    
    override func setUp() {
        super.setUp()
        Configuration.plistName = "testInfo"
        Configuration.restoreDefaults()
        versionNumber = Bundle(for: RidesAuthenticationDeeplink.self).object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
    
    override func tearDown() {
        Configuration.restoreDefaults()
        super.tearDown()
    }
    
    func testScheme() {
        let authenticationDeeplink = RidesAuthenticationDeeplink(scopes:[])
        XCTAssertEqual(authenticationDeeplink.url.scheme, "uberauth")
    }
    
    func testHost() {
        let authenticationDeeplink = RidesAuthenticationDeeplink(scopes:[])
        XCTAssertEqual(authenticationDeeplink.url.host, "connect")
    }
    
    func testPath() {
        let authenticationDeeplink = RidesAuthenticationDeeplink(scopes:[])
        XCTAssertEqual(authenticationDeeplink.url.path, "")
    }
    
    func testDeeplinkURL() {
        let scopes = [UberScope.allTrips, UberScope.profile]
        let authenticationDeeplink = RidesAuthenticationDeeplink(scopes:scopes)
        let expectedURLPrefix = "uberauth://connect?"
        
        XCTAssertTrue(authenticationDeeplink.url.absoluteString.hasPrefix(expectedURLPrefix))
    }
}


