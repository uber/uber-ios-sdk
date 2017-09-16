//
//  AuthenticationURLUtilityTests.swift
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

class AuthenticationURLUtilityTests: XCTestCase {
    
    private var versionNumber: String?
    
    override func setUp() {
        super.setUp()
        Configuration.bundle = Bundle(for: type(of: self))
        Configuration.plistName = "testInfo"
        Configuration.restoreDefaults()
        versionNumber = Bundle(for: RideParameters.self).object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
    
    override func tearDown() {
        Configuration.restoreDefaults()
        super.tearDown()
    }
    
    func testBuildQueryParameters_withSingleScope() {
        
        let scopes = [RidesScope.rideWidgets]
        
        let expectedScopes = scopes.toRidesScopeString()
        let expectedClientID = "testClientID"
        let expectedAppName = "My Awesome App"
        let expectedCallbackURI = "testURI://uberConnectNative"
        let expectedSDK = "ios"
        let expectedSDKVersion = versionNumber
        
        let scopeQueryItem = URLQueryItem(name: AuthenticationURLUtility.scopesKey, value: expectedScopes)
        let clientIDQueryItem = URLQueryItem(name: AuthenticationURLUtility.clientIDKey, value: expectedClientID)
        let appNameQueryItem = URLQueryItem(name: AuthenticationURLUtility.appNameKey, value: expectedAppName)
        let callbackURIQueryItem = URLQueryItem(name: AuthenticationURLUtility.callbackURIKey, value: expectedCallbackURI)
        let sdkQueryItem = URLQueryItem(name: AuthenticationURLUtility.sdkKey, value: expectedSDK)
        let sdkVersionQueryItem = URLQueryItem(name: AuthenticationURLUtility.sdkVersionKey, value: expectedSDKVersion)
        
        let expectedQueryItems = [scopeQueryItem, clientIDQueryItem, appNameQueryItem, callbackURIQueryItem, sdkQueryItem, sdkVersionQueryItem]
        let comparisonSet = NSSet(array: expectedQueryItems)
        
        let testQueryItems = AuthenticationURLUtility.buildQueryParameters(scopes)
        let testComparisonSet = NSSet(array:testQueryItems)
        
        XCTAssertEqual(comparisonSet, testComparisonSet)
    }
    
    func testBuildQueryParameters_withMultipleScopes() {
        
        let scopes = [RidesScope.rideWidgets, RidesScope.allTrips, RidesScope.history]
        
        let expectedScopes = scopes.toRidesScopeString()
        let expectedClientID = "testClientID"
        let expectedAppName = "My Awesome App"
        let expectedCallbackURI = "testURI://uberConnectNative"
        let expectedSDK = "ios"
        let expectedSDKVersion = versionNumber
        
        let scopeQueryItem = URLQueryItem(name: AuthenticationURLUtility.scopesKey, value: expectedScopes)
        let clientIDQueryItem = URLQueryItem(name: AuthenticationURLUtility.clientIDKey, value: expectedClientID)
        let appNameQueryItem = URLQueryItem(name: AuthenticationURLUtility.appNameKey, value: expectedAppName)
        let callbackURIQueryItem = URLQueryItem(name: AuthenticationURLUtility.callbackURIKey, value: expectedCallbackURI)
        let sdkQueryItem = URLQueryItem(name: AuthenticationURLUtility.sdkKey, value: expectedSDK)
        let sdkVersionQueryItem = URLQueryItem(name: AuthenticationURLUtility.sdkVersionKey, value: expectedSDKVersion)
        
        let expectedQueryItems = [scopeQueryItem, clientIDQueryItem, appNameQueryItem, callbackURIQueryItem, sdkQueryItem, sdkVersionQueryItem]
        let comparisonSet = NSSet(array: expectedQueryItems)
        
        let testQueryItems = AuthenticationURLUtility.buildQueryParameters(scopes)
        let testComparisonSet = NSSet(array:testQueryItems)
        
        XCTAssertEqual(comparisonSet, testComparisonSet)
    }
    
    func testShouldHandleRedirectURL() {
        let testRedirectURLString = "test://handleThis"
        guard let testRedirectURL = URL(string: testRedirectURLString) else {
            XCTFail()
            return
        }
        Configuration.shared.setCallbackURIString(testRedirectURLString, type: .implicit)
        XCTAssertFalse(AuthenticationURLUtility.shouldHandleRedirectURL(testRedirectURL, type: .general))
        XCTAssertFalse(AuthenticationURLUtility.shouldHandleRedirectURL(testRedirectURL, type: .native))
        XCTAssertFalse(AuthenticationURLUtility.shouldHandleRedirectURL(testRedirectURL, type: .authorizationCode))
        
        XCTAssertTrue(AuthenticationURLUtility.shouldHandleRedirectURL(testRedirectURL, type: .implicit))
        
        Configuration.shared.setCallbackURIString(nil, type: .implicit)
        
        XCTAssertFalse(AuthenticationURLUtility.shouldHandleRedirectURL(testRedirectURL, type: .implicit))
    }
}
