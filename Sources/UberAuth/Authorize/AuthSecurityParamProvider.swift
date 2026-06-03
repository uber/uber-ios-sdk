//
//  AuthSecurityParamProvider.swift
//  UberAuth
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

/// Manages per-request nonce and state for a single authorization flow.
final class AuthSecurityParamProvider {

    private let clientNonce: String?
    private(set) var nonce: String?
    private(set) var state: String?

    init(nonce: String? = nil) {
        self.clientNonce = nonce
    }

    /// Generates fresh nonce and state values for a new authorization request.
    func begin() {
        nonce = clientNonce ?? Nonce.generate()
        state = State.generate()
    }

    /// Consumes and clears the pending state, returning its value.
    /// Called by `handle(response:)` on the native deep-link path.
    func consumeState() -> String? {
        defer { state = nil }
        return state
    }

    /// Clears all pending values and returns the nonce.
    /// Called once the authorization flow completes (success or failure).
    func end() -> String? {
        defer { nonce = nil; state = nil }
        return nonce
    }
}
