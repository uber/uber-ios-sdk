//
//  ConfigurationTests.swift
//  UberRides
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
@testable import UberRides

class ConfigurationTests: XCTestCase {

    private let defaultClientID = "testClientID"
    private let defaultDisplayName = "My Awesome App"
    private let defaultCallbackString = "testURI://uberConnect"
    private let defaultGeneralCallbackString = "testURI://uberConnectGeneral"
    private let defaultAuthorizationCodeCallbackString = "testURI://uberConnectAuthorizationCode"
    private let defaultImplicitCallbackString = "testURI://uberConnectImplicit"
    private let defaultNativeCallbackString = "testURI://uberConnectNative"
    private let defaultServerToken = "testServerToken"
    private let defaultAccessTokenIdentifier = "RidesAccessTokenKey"
    private let defaultRegion = Region.default
    private let defaultSandbox = false
    
    override func setUp() {
        super.setUp()
        Configuration.restoreDefaults()
        Configuration.plistName = "testInfo"
        Configuration.bundle = Bundle(for: type(of: self))
    }
    
    override func tearDown() {
        Configuration.restoreDefaults()
        super.tearDown()
    }
    
    //MARK: Reset Test
    
    func testConfiguration_restoreDefaults() {
        
        let newClientID = "newID"
        let newCallback = "newCallback://"
        let newDisplay = "newDisplay://"
        let newServerToken = "newserver"
        let newGroup = "new group"
        let newTokenId = "newTokenID"
        let newRegion = Region.china
        let newSandbox = true
        
        Configuration.setClientID(newClientID)
        Configuration.setCallbackURIString(newCallback)
        Configuration.setAppDisplayName(newDisplay)
        Configuration.setServerToken(newServerToken)
        Configuration.setDefaultKeychainAccessGroup(newGroup)
        Configuration.setDefaultAccessTokenIdentifier(newTokenId)
        Configuration.setRegion(newRegion)
        Configuration.setSandboxEnabled(newSandbox)
        
        XCTAssertEqual(newClientID, Configuration.shared.clientID)
        XCTAssertEqual(newCallback, Configuration.shared.getCallbackURIString())
        XCTAssertEqual(newDisplay, Configuration.getAppDisplayName())
        XCTAssertEqual(newServerToken, Configuration.getServerToken())
        XCTAssertEqual(newGroup, Configuration.shared.defaultKeychainAccessGroup)
        XCTAssertEqual(newTokenId, Configuration.shared.defaultAccessTokenIdentifier)
        XCTAssertEqual(newRegion, Configuration.shared.region)
        XCTAssertEqual(newSandbox, Configuration.shared.sandboxEnabled)
        Configuration.restoreDefaults()
        
        XCTAssertEqual(Configuration.plistName, "Info")
        XCTAssertEqual(Configuration.bundle, Bundle.main)
        
        Configuration.plistName = "testInfo"
        Configuration.bundle = Bundle(for: type(of: self))
        
        XCTAssertEqual(Configuration.shared.clientID, defaultClientID)
        XCTAssertEqual(defaultGeneralCallbackString, Configuration.shared.getCallbackURIString())
        XCTAssertEqual(defaultDisplayName, Configuration.getAppDisplayName())
        XCTAssertEqual(defaultServerToken, Configuration.getServerToken())
        XCTAssertEqual("", Configuration.shared.defaultKeychainAccessGroup)
        XCTAssertEqual(defaultAccessTokenIdentifier, Configuration.shared.defaultAccessTokenIdentifier)
        XCTAssertEqual(defaultRegion, Configuration.shared.region)
        XCTAssertEqual(defaultSandbox, Configuration.shared.sandboxEnabled)
    }
    
    //MARK: Client ID Tests
    
    func testClientID_getDefault() {
        XCTAssertEqual(defaultClientID, Configuration.shared.clientID)
    }
    
    func testClientID_overwriteDefault() {
        let clientID = "clientID"
        Configuration.setClientID(clientID)
        XCTAssertEqual(clientID, Configuration.shared.clientID)
    }
    
    func testClientID_resetDefault() {
        Configuration.setClientID("alternateClient")
        
        Configuration.setClientID(nil)
        
        XCTAssertEqual(defaultClientID, Configuration.shared.clientID)
    }
    
    //MARK: Callback URI String Tests
    
    func testCallbackURIString_getDefault() {
        XCTAssertEqual(defaultGeneralCallbackString, Configuration.shared.getCallbackURIString())
    }
    
    func testCallbackURIString_overwriteDefault() {
        let callbackURIString = "callback://test"
        Configuration.setCallbackURIString(callbackURIString)
        
        XCTAssertEqual(callbackURIString, Configuration.shared.getCallbackURIString())
    }
    
    func testCallbackURIString_resetDefault() {
        Configuration.setCallbackURIString("testCallback://asdf")
        
        Configuration.setCallbackURIString(nil)
        
        XCTAssertEqual(defaultGeneralCallbackString, Configuration.shared.getCallbackURIString())
    }
    
    func testCallbackURIString_getDefault_getTypes() {
        XCTAssertEqual(defaultGeneralCallbackString, Configuration.shared.getCallbackURIString(for: .general))
        XCTAssertEqual(defaultAuthorizationCodeCallbackString, Configuration.shared.getCallbackURIString(for: .authorizationCode))
        XCTAssertEqual(defaultImplicitCallbackString, Configuration.shared.getCallbackURIString(for: .implicit))
        XCTAssertEqual(defaultNativeCallbackString, Configuration.shared.getCallbackURIString(for: .native))
    }
    
    func testCallbackURIString_overwriteDefault_allTypes() {
        let generalCallbackString = "testURI://uberConnectGeneralNew"
        let authorizationCodeCallbackString = "testURI://uberConnectAuthorizationCodeNew"
        let implicitCallbackString = "testURI://uberConnectImplicitNew"
        let nativeCallbackString = "testURI://uberConnectNativeNew"
        
        Configuration.setCallbackURIString(generalCallbackString, type: .general)
        Configuration.setCallbackURIString(authorizationCodeCallbackString, type: .authorizationCode)
        Configuration.setCallbackURIString(implicitCallbackString, type: .implicit)
        Configuration.setCallbackURIString(nativeCallbackString, type: .native)
        
        XCTAssertEqual(generalCallbackString, Configuration.shared.getCallbackURIString(for: .general))
        XCTAssertEqual(authorizationCodeCallbackString, Configuration.shared.getCallbackURIString(for: .authorizationCode))
        XCTAssertEqual(implicitCallbackString, Configuration.shared.getCallbackURIString(for: .implicit))
        XCTAssertEqual(nativeCallbackString, Configuration.shared.getCallbackURIString(for: .native))
    }
    
    func testCallbackURIString_resetDefault_allTypes() {
        let generalCallbackString = "testURI://uberConnectGeneralNew"
        let authorizationCodeCallbackString = "testURI://uberConnectAuthorizationCodeNew"
        let implicitCallbackString = "testURI://uberConnectImplicitNew"
        let nativeCallbackString = "testURI://uberConnectNativeNew"
        
        Configuration.setCallbackURIString(generalCallbackString, type: .general)
        Configuration.setCallbackURIString(authorizationCodeCallbackString, type: .authorizationCode)
        Configuration.setCallbackURIString(implicitCallbackString, type: .implicit)
        Configuration.setCallbackURIString(nativeCallbackString, type: .native)
        
        Configuration.setCallbackURIString(nil, type: .general)
        Configuration.setCallbackURIString(nil, type: .authorizationCode)
        Configuration.setCallbackURIString(nil, type: .implicit)
        Configuration.setCallbackURIString(nil, type: .native)
        
        XCTAssertEqual(defaultGeneralCallbackString, Configuration.shared.getCallbackURIString(for: .general))
        XCTAssertEqual(defaultAuthorizationCodeCallbackString, Configuration.shared.getCallbackURIString(for: .authorizationCode))
        XCTAssertEqual(defaultImplicitCallbackString, Configuration.shared.getCallbackURIString(for: .implicit))
        XCTAssertEqual(defaultNativeCallbackString, Configuration.shared.getCallbackURIString(for: .native))
    }
    
    func testCallbackURIString_resetDefault_oneType() {
        let generalCallbackString = "testURI://uberConnectGeneralNew"
        let authorizationCodeCallbackString = "testURI://uberConnectAuthorizationCodeNew"
        let implicitCallbackString = "testURI://uberConnectImplicitNew"
        let nativeCallbackString = "testURI://uberConnectNativeNew"
        
        Configuration.setCallbackURIString(generalCallbackString, type: .general)
        Configuration.setCallbackURIString(authorizationCodeCallbackString, type: .authorizationCode)
        Configuration.setCallbackURIString(implicitCallbackString, type: .implicit)
        Configuration.setCallbackURIString(nativeCallbackString, type: .native)

        Configuration.setCallbackURIString(nil, type: .native)
        
        XCTAssertEqual(generalCallbackString, Configuration.shared.getCallbackURIString(for: .general))
        XCTAssertEqual(authorizationCodeCallbackString, Configuration.shared.getCallbackURIString(for: .authorizationCode))
        XCTAssertEqual(implicitCallbackString, Configuration.shared.getCallbackURIString(for: .implicit))
        XCTAssertEqual(defaultNativeCallbackString, Configuration.shared.getCallbackURIString(for: .native))
    }
    
    func testCallbackURIStringFallback_whenCallbackURIsMissing() {
        Configuration.plistName = "testInfoMissingCallbacks"
        XCTAssertEqual(defaultCallbackString, Configuration.shared.getCallbackURIString(for: .general))
        XCTAssertEqual(defaultCallbackString, Configuration.shared.getCallbackURIString(for: .authorizationCode))
        XCTAssertEqual(defaultCallbackString, Configuration.shared.getCallbackURIString(for: .implicit))
        XCTAssertEqual(defaultCallbackString, Configuration.shared.getCallbackURIString(for: .native))
    }
    
    func testCallbackURIStringFallbackUsesGeneralOverride_whenCallbackURIsMissing() {
        Configuration.plistName = "testInfoMissingCallbacks"
        let override = "testURI://override"
        Configuration.setCallbackURIString(override, type: .general)
        XCTAssertEqual(override, Configuration.shared.getCallbackURIString(for: .general))
        XCTAssertEqual(override, Configuration.shared.getCallbackURIString(for: .authorizationCode))
        XCTAssertEqual(override, Configuration.shared.getCallbackURIString(for: .implicit))
        XCTAssertEqual(override, Configuration.shared.getCallbackURIString(for: .native))
    }
    
    //MARK: App Display Name Tests
    
    func testAppDisplayName_getDefault() {
        XCTAssertEqual(defaultDisplayName, Configuration.getAppDisplayName())
    }
    
    func testAppDisplayName_overwriteDefault() {
        let appDisplayName = "Test App"
        Configuration.setAppDisplayName(appDisplayName)
        
        XCTAssertEqual(appDisplayName, Configuration.getAppDisplayName())
    }
    
    func testAppDisplayName_resetDefault() {
        Configuration.setAppDisplayName("new app name")
        
        Configuration.setAppDisplayName(nil)
        
        XCTAssertEqual(defaultDisplayName, Configuration.getAppDisplayName())
    }
    
    //MARK: Server Token Tests
    
    func testServerToken_getDefault() {
        XCTAssertEqual(defaultServerToken, Configuration.getServerToken())
    }
    
    func testServerToken_overwriteDefault() {
        let serverToken = "nonDefaultToken"
        Configuration.setServerToken(serverToken)
        
        XCTAssertEqual(serverToken, Configuration.getServerToken())
    }
    
    func testServerToken_resetDefault() {
        Configuration.setServerToken("nonDefaultToken")
        
        Configuration.setServerToken(nil)
        
        XCTAssertEqual(defaultServerToken, Configuration.getServerToken())
    }
    
    //MARK: Keychain Access Group Tests
    
    func testDefaultKeychainAccessGroup_getDefault() {
        XCTAssertEqual("", Configuration.shared.defaultKeychainAccessGroup)
    }
    
    func testDefaultKeychainAccessGroup_overwriteDefault() {
        let defaultKeychainAccessGroup = "accessGroup"
        Configuration.setDefaultKeychainAccessGroup(defaultKeychainAccessGroup)
        
        XCTAssertEqual(defaultKeychainAccessGroup, Configuration.shared.defaultKeychainAccessGroup)
    }
    
    func testDefaultKeychainAccessGroup_resetDefault() {
        Configuration.setDefaultKeychainAccessGroup("accessGroup")
        
        Configuration.setDefaultKeychainAccessGroup(nil)
        
        XCTAssertEqual("", Configuration.shared.defaultKeychainAccessGroup)
    }
    
    //MARK: Access token identifier tests
    
    func testDefaultAccessTokenIdentifier_getDefault() {
        XCTAssertEqual(defaultAccessTokenIdentifier, Configuration.shared.defaultAccessTokenIdentifier)
    }
    
    func testDefaultAccessTokenIdentifier_overwriteDefault() {
        let newIdentifier = "newIdentifier"
        Configuration.setDefaultAccessTokenIdentifier(newIdentifier)
        
        XCTAssertEqual(newIdentifier, Configuration.shared.defaultAccessTokenIdentifier)
    }
    
    func testDefaultAccessTokenIdentifier_resetDefault() {
        Configuration.setDefaultAccessTokenIdentifier("newIdentifier")

        Configuration.setDefaultAccessTokenIdentifier(nil)
        
        XCTAssertEqual(defaultAccessTokenIdentifier, Configuration.shared.defaultAccessTokenIdentifier)
    }
    
    //MARK: Region Tests
    
    func testRegion_getDefault() {
        XCTAssertEqual(defaultRegion, Configuration.shared.region)
    }
    
    func testRegion_overwriteDefault() {
        let newRegion = Region.china
        Configuration.setRegion(newRegion)
        
        XCTAssertEqual(newRegion, Configuration.shared.region)
    }
    
    //MARK: Sandbox Tests
    
    func testSandbox_getDefault() {
        XCTAssertEqual(defaultSandbox, Configuration.shared.sandboxEnabled)
    }
    
    func testSandbox_overwriteDefault() {
        let newSandbox = true
        Configuration.setSandboxEnabled(newSandbox)
        
        XCTAssertEqual(newSandbox, Configuration.shared.sandboxEnabled)
    }
}
