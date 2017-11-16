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
@testable import UberCore

class ConfigurationTests: XCTestCase {

    private let defaultClientID = "testClientID"
    private let defaultDisplayName = "My Awesome App"
    private let defaultCallback = URL(string: "testURI://uberConnect")!
    private let defaultGeneralCallback = URL(string: "testURI://uberConnectGeneral")!
    private let defaultAuthorizationCodeCallback = URL(string: "testURI://uberConnectAuthorizationCode")!
    private let defaultImplicitCallback = URL(string: "testURI://uberConnectImplicit")!
    private let defaultNativeCallback = URL(string: "testURI://uberConnectNative")!
    private let defaultServerToken = "testServerToken"
    private let defaultAccessTokenIdentifier = "RidesAccessTokenKey"
    private let defaultSandbox = false
    
    override func setUp() {
        super.setUp()
        Configuration.bundle = Bundle.main
        Configuration.plistName = "testInfo"
        Configuration.restoreDefaults()
    }
    
    override func tearDown() {
        Configuration.restoreDefaults()
        super.tearDown()
    }
    
    //MARK: Reset Test
    
    func testConfiguration_restoreDefaults() {
        
        let newClientID = "newID"
        let newCallback = URL(string: "newCallback://")!
        let newDisplay = "newDisplay://"
        let newServerToken = "newserver"
        let newGroup = "new group"
        let newTokenId = "newTokenID"
        let newSandbox = true
        
        Configuration.shared.clientID = newClientID
        Configuration.shared.setCallbackURI(newCallback)
        Configuration.shared.appDisplayName = newDisplay
        Configuration.shared.serverToken = newServerToken
        Configuration.shared.defaultKeychainAccessGroup = newGroup
        Configuration.shared.defaultAccessTokenIdentifier = newTokenId
        Configuration.shared.isSandbox = newSandbox
        
        XCTAssertEqual(newClientID, Configuration.shared.clientID)
        XCTAssertEqual(newCallback, Configuration.shared.getCallbackURI())
        XCTAssertEqual(newDisplay, Configuration.shared.appDisplayName)
        XCTAssertEqual(newServerToken, Configuration.shared.serverToken)
        XCTAssertEqual(newGroup, Configuration.shared.defaultKeychainAccessGroup)
        XCTAssertEqual(newTokenId, Configuration.shared.defaultAccessTokenIdentifier)
        XCTAssertEqual(newSandbox, Configuration.shared.isSandbox)
        Configuration.restoreDefaults()
        
        Configuration.plistName = "testInfo"
        Configuration.bundle = Bundle.main
        
        XCTAssertEqual(Configuration.shared.clientID, defaultClientID)
        XCTAssertEqual(defaultGeneralCallback, Configuration.shared.getCallbackURI())
        XCTAssertEqual(defaultDisplayName, Configuration.shared.appDisplayName)
        XCTAssertEqual(defaultServerToken, Configuration.shared.serverToken)
        XCTAssertEqual("", Configuration.shared.defaultKeychainAccessGroup)
        XCTAssertEqual(defaultAccessTokenIdentifier, Configuration.shared.defaultAccessTokenIdentifier)
        XCTAssertEqual(defaultSandbox, Configuration.shared.isSandbox)
    }
    
    //MARK: Client ID Tests
    
    func testClientID_getDefault() {
        XCTAssertEqual(defaultClientID, Configuration.shared.clientID)
    }
    
    func testClientID_overwriteDefault() {
        let clientID = "clientID"
        Configuration.shared.clientID = clientID
        XCTAssertEqual(clientID, Configuration.shared.clientID)
    }
    
    //MARK: Callback URI String Tests
    
    func testCallbackURI_getDefault() {
        XCTAssertEqual(defaultGeneralCallback, Configuration.shared.getCallbackURI())
    }
    
    func testCallbackURI_overwriteDefault() {
        let callbackURI = URL(string: "callback://test")!
        Configuration.shared.setCallbackURI(callbackURI)
        
        XCTAssertEqual(callbackURI, Configuration.shared.getCallbackURI())
    }
    
    func testCallbackURI_getDefault_getTypes() {
        XCTAssertEqual(defaultGeneralCallback, Configuration.shared.getCallbackURI(for: .general))
        XCTAssertEqual(defaultAuthorizationCodeCallback, Configuration.shared.getCallbackURI(for: .authorizationCode))
        XCTAssertEqual(defaultImplicitCallback, Configuration.shared.getCallbackURI(for: .implicit))
        XCTAssertEqual(defaultNativeCallback, Configuration.shared.getCallbackURI(for: .native))
    }
    
    func testCallbackURI_overwriteDefault_allTypes() {
        let generalCallback = URL(string: "testURI://uberConnectGeneralNew")!
        let authorizationCodeCallback = URL(string: "testURI://uberConnectAuthorizationCodeNew")!
        let implicitCallback = URL(string: "testURI://uberConnectImplicitNew")!
        let nativeCallback = URL(string: "testURI://uberConnectNativeNew")!
        
        Configuration.shared.setCallbackURI(generalCallback, type: .general)
        Configuration.shared.setCallbackURI(authorizationCodeCallback, type: .authorizationCode)
        Configuration.shared.setCallbackURI(implicitCallback, type: .implicit)
        Configuration.shared.setCallbackURI(nativeCallback, type: .native)
        
        XCTAssertEqual(generalCallback, Configuration.shared.getCallbackURI(for: .general))
        XCTAssertEqual(authorizationCodeCallback, Configuration.shared.getCallbackURI(for: .authorizationCode))
        XCTAssertEqual(implicitCallback, Configuration.shared.getCallbackURI(for: .implicit))
        XCTAssertEqual(nativeCallback, Configuration.shared.getCallbackURI(for: .native))
    }
    
    func testCallbackURI_resetDefault_allTypes() {
        let generalCallback = URL(string: "testURI://uberConnectGeneralNew")!
        let authorizationCodeCallback = URL(string: "testURI://uberConnectAuthorizationCodeNew")!
        let implicitCallback = URL(string: "testURI://uberConnectImplicitNew")!
        let nativeCallback = URL(string: "testURI://uberConnectNativeNew")!
        
        Configuration.shared.setCallbackURI(generalCallback, type: .general)
        Configuration.shared.setCallbackURI(authorizationCodeCallback, type: .authorizationCode)
        Configuration.shared.setCallbackURI(implicitCallback, type: .implicit)
        Configuration.shared.setCallbackURI(nativeCallback, type: .native)
        
        Configuration.shared.setCallbackURI(nil, type: .general)
        Configuration.shared.setCallbackURI(nil, type: .authorizationCode)
        Configuration.shared.setCallbackURI(nil, type: .implicit)
        Configuration.shared.setCallbackURI(nil, type: .native)
        
        XCTAssertEqual(defaultGeneralCallback, Configuration.shared.getCallbackURI(for: .general))
        XCTAssertEqual(defaultAuthorizationCodeCallback, Configuration.shared.getCallbackURI(for: .authorizationCode))
        XCTAssertEqual(defaultImplicitCallback, Configuration.shared.getCallbackURI(for: .implicit))
        XCTAssertEqual(defaultNativeCallback, Configuration.shared.getCallbackURI(for: .native))
    }
    
    func testCallbackURI_resetDefault_oneType() {
        let generalCallback = URL(string: "testURI://uberConnectGeneralNew")!
        let authorizationCodeCallback = URL(string: "testURI://uberConnectAuthorizationCodeNew")!
        let implicitCallback = URL(string: "testURI://uberConnectImplicitNew")!
        let nativeCallback = URL(string: "testURI://uberConnectNativeNew")!
        
        Configuration.shared.setCallbackURI(generalCallback, type: .general)
        Configuration.shared.setCallbackURI(authorizationCodeCallback, type: .authorizationCode)
        Configuration.shared.setCallbackURI(implicitCallback, type: .implicit)
        Configuration.shared.setCallbackURI(nativeCallback, type: .native)

        Configuration.shared.setCallbackURI(nil, type: .native)
        
        XCTAssertEqual(generalCallback, Configuration.shared.getCallbackURI(for: .general))
        XCTAssertEqual(authorizationCodeCallback, Configuration.shared.getCallbackURI(for: .authorizationCode))
        XCTAssertEqual(implicitCallback, Configuration.shared.getCallbackURI(for: .implicit))
        XCTAssertEqual(defaultNativeCallback, Configuration.shared.getCallbackURI(for: .native))
    }
    
    func testCallbackURIFallback_whenCallbackURIsMissing() {
        Configuration.bundle = Bundle(for: Configuration.self)
        Configuration.plistName = "testInfoMissingCallbacks"
        Configuration.restoreDefaults()
        XCTAssertEqual(defaultCallback, Configuration.shared.getCallbackURI(for: .general))
        XCTAssertEqual(defaultCallback, Configuration.shared.getCallbackURI(for: .authorizationCode))
        XCTAssertEqual(defaultCallback, Configuration.shared.getCallbackURI(for: .implicit))
        XCTAssertEqual(defaultCallback, Configuration.shared.getCallbackURI(for: .native))
    }
    
    func testCallbackURIFallbackUsesGeneralOverride_whenCallbackURIsMissing() {
        Configuration.bundle = Bundle(for: Configuration.self)
        Configuration.plistName = "testInfoMissingCallbacks"
        Configuration.restoreDefaults()
        let override = URL(string: "testURI://override")!
        Configuration.shared.setCallbackURI(override, type: .general)
        XCTAssertEqual(override, Configuration.shared.getCallbackURI(for: .general))
        XCTAssertEqual(override, Configuration.shared.getCallbackURI(for: .authorizationCode))
        XCTAssertEqual(override, Configuration.shared.getCallbackURI(for: .implicit))
        XCTAssertEqual(override, Configuration.shared.getCallbackURI(for: .native))
    }
    
    //MARK: App Display Name Tests
    
    func testAppDisplayName_getDefault() {
        XCTAssertEqual(defaultDisplayName, Configuration.shared.appDisplayName)
    }
    
    func testAppDisplayName_overwriteDefault() {
        let appDisplayName = "Test App"
        Configuration.shared.appDisplayName = appDisplayName
        
        XCTAssertEqual(appDisplayName, Configuration.shared.appDisplayName)
    }
    
    //MARK: Server Token Tests
    
    func testServerToken_getDefault() {
        XCTAssertEqual(defaultServerToken, Configuration.shared.serverToken)
    }
    
    func testServerToken_overwriteDefault() {
        let serverToken = "nonDefaultToken"
        Configuration.shared.serverToken = serverToken
        
        XCTAssertEqual(serverToken, Configuration.shared.serverToken)
    }
    
    //MARK: Keychain Access Group Tests
    
    func testDefaultKeychainAccessGroup_getDefault() {
        XCTAssertEqual("", Configuration.shared.defaultKeychainAccessGroup)
    }
    
    func testDefaultKeychainAccessGroup_overwriteDefault() {
        let defaultKeychainAccessGroup = "accessGroup"
        Configuration.shared.defaultKeychainAccessGroup = defaultKeychainAccessGroup
        
        XCTAssertEqual(defaultKeychainAccessGroup, Configuration.shared.defaultKeychainAccessGroup)
    }

    //MARK: Access token identifier tests
    
    func testDefaultAccessTokenIdentifier_getDefault() {
        XCTAssertEqual(defaultAccessTokenIdentifier, Configuration.shared.defaultAccessTokenIdentifier)
    }
    
    func testDefaultAccessTokenIdentifier_overwriteDefault() {
        let newIdentifier = "newIdentifier"
        Configuration.shared.defaultAccessTokenIdentifier = newIdentifier
        
        XCTAssertEqual(newIdentifier, Configuration.shared.defaultAccessTokenIdentifier)
    }

    //MARK: Sandbox Tests
    
    func testSandbox_getDefault() {
        XCTAssertEqual(defaultSandbox, Configuration.shared.isSandbox)
    }
    
    func testSandbox_overwriteDefault() {
        let newSandbox = true
        Configuration.shared.isSandbox = newSandbox
        
        XCTAssertEqual(newSandbox, Configuration.shared.isSandbox)
    }
}
