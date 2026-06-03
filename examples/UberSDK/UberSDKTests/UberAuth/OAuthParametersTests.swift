//
//  OAuthParametersTests.swift
//  UberSDKTests
//
//  Copyright © 2026 Uber Technologies, Inc. All rights reserved.
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

final class OAuthParametersTests: XCTestCase {

    // MARK: - Nonce

    func test_nonce_generate_producesNonEmptyString() {
        XCTAssertFalse(Nonce.generate().isEmpty)
    }

    func test_nonce_generate_base64urlCharactersOnly() {
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_"))
        let nonce = Nonce.generate()
        XCTAssertTrue(nonce.unicodeScalars.allSatisfy { allowed.contains($0) },
                      "Nonce contains non-base64url characters: \(nonce)")
    }

    func test_nonce_generate_minimumEntropyLength() {
        XCTAssertGreaterThanOrEqual(Nonce.generate().count, 43)
    }

    func test_nonce_generate_uniqueValues() {
        XCTAssertNotEqual(Nonce.generate(), Nonce.generate())
    }

    // MARK: - State

    func test_state_generate_producesNonEmptyString() {
        XCTAssertFalse(State.generate().isEmpty)
    }

    func test_state_generate_base64urlCharactersOnly() {
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_"))
        let state = State.generate()
        XCTAssertTrue(state.unicodeScalars.allSatisfy { allowed.contains($0) },
                      "State contains non-base64url characters: \(state)")
    }

    func test_state_generate_minimumEntropyLength() {
        XCTAssertGreaterThanOrEqual(State.generate().count, 43)
    }

    func test_state_generate_uniqueValues() {
        XCTAssertNotEqual(State.generate(), State.generate())
    }
}
