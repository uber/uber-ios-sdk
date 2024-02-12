//
//  UberScopeUtilTests.swift
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
@testable import UberCore

class UberScopeExtensionsTests: XCTestCase {

    func testUberScopeToString_withValidScopes()
    {
        let scopes : [UberScope] = Array(arrayLiteral: UberScope.profile, UberScope.places)
        
        let expectedString = "\(UberScope.profile.rawValue) \(UberScope.places.rawValue)"
        let scopeString = scopes.toUberScopeString()
        
        XCTAssertEqual(expectedString, scopeString)
    }
    
    func testUberScopeToString_withNoScopes()
    {
        let scopes : [UberScope] = [UberScope]()
        
        let expectedString = ""
        let scopeString = scopes.toUberScopeString()
        
        XCTAssertEqual(expectedString, scopeString)
    }
    
    func testUberScopeToString_withValidScopesUsingSet()
    {
        let scopes : Set<UberScope> = Set<UberScope>(arrayLiteral: UberScope.profile, UberScope.places)
        
        let scopeString = scopes.toUberScopeString()
        
        var testSet : Set<UberScope> = Set<UberScope>()
        for scopeString in scopeString.components(separatedBy: " ") {
            let scope = UberScope(scopeString: scopeString)
            testSet.insert(scope)
        }
        
        XCTAssertEqual(scopes, testSet)
    }
    
    func testUberScopeToString_withNoScopes_usingSet()
    {
        let scopes : Set<UberScope> = Set<UberScope>()
        
        let expectedString = ""
        let scopeString = scopes.toUberScopeString()
        
        XCTAssertEqual(expectedString, scopeString)
    }
    
    func testStringToUberScope_withValidScopes()
    {
        let expectedScopes : [UberScope] = Array(arrayLiteral: UberScope.profile, UberScope.places)
        
        let scopeString = "\(UberScope.profile.rawValue) \(UberScope.places.rawValue)"

        let scopes = scopeString.toUberScopesArray()
        
        XCTAssertEqual(scopes, expectedScopes)
    }

    func testStringToUberScope_withCustomScopes()
    {
        let expectedScopes : [UberScope] = [ UberScope(scopeString: "custom_scope") ]
        
        let scopeString = "Custom_Scope"
        
        let scopes = scopeString.toUberScopesArray()
        
        XCTAssertEqual(scopes, expectedScopes)
    }
    
    func testStringToUberScope_withCustomAndValidScopes()
    {
        let expectedScopes : [UberScope] = [ UberScope(scopeString: "CUSTOM_SCOPE"), UberScope.places ]
        
        let scopeString = "custom_scope \(UberScope.places.rawValue)"
        
        let scopes = scopeString.toUberScopesArray()
        
        XCTAssertEqual(scopes, expectedScopes)
    }
    
    func testStringToUberScope_caseInsensitive()
    {
        let expectedScopes : [UberScope] = [ UberScope.places, UberScope.history ]
        
        let scopeString = "plAcEs HISTORY"
        
        let scopes = scopeString.toUberScopesArray()
        
        XCTAssertEqual(scopes, expectedScopes)
    }
}
