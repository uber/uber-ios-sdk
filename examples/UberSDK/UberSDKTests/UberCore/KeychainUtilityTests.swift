//
//  KeychainUtility.swift
//  UberCore
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


import XCTest
@testable import UberCore

final class KeychainUtilityTests: XCTestCase {
    
    private let keychainUtility = KeychainUtility()
    
    override func setUp() {
        super.setUp()
        
        _ = keychainUtility.delete(key: "test_object")
    }
    
    override func tearDown() {
        super.tearDown()
        
        _ = keychainUtility.delete(key: "test_object")
    }
    
    func test_save() {
        let testObject = TestObject(
            name: "test",
            value: 5
        )
                
        let saved = keychainUtility.save(testObject, for: "test_object")
        XCTAssertTrue(saved)
    }
    
    func test_get() {
        let testObject = TestObject(
            name: "test",
            value: 5
        )
        
        _ = keychainUtility.save(testObject, for: "test_object")
        let retrievedObject: TestObject? = keychainUtility.get(key: "test_object")
        
        XCTAssertEqual(testObject, retrievedObject)
    }
    
    func test_delete() {
        let testObject = TestObject(
            name: "test",
            value: 5
        )
        
        _ = keychainUtility.save(testObject, for: "test_object")
        let deleted = keychainUtility.delete(key: "test_object")
        XCTAssertTrue(deleted)
        
        let retrievedObject: TestObject? = keychainUtility.get(key: "test_object")
        XCTAssertNil(retrievedObject)
    }
    
    private struct TestObject: Codable, Equatable {
        let name: String
        let value: Int
    }
}
