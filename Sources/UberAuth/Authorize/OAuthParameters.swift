//
//  OAuthParameters.swift
//  UberAuth
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


import Foundation
import Security

// MARK: - Nonce

enum Nonce {

    /// Generates a cryptographically random nonce — 32 bytes from SecRandomCopyBytes,
    /// base64url-encoded (RFC 4648 §5, no padding). Sent in /authorize and echoed back
    /// in the id_token claim so the partner backend can detect replay attacks.
    static func generate() -> String {
        randomBase64URL()
    }

    /// Decodes the JWT payload (without verifying the signature) and returns the `nonce` claim.
    static func claim(from jwt: String) -> String? {
        let parts = jwt.split(separator: ".", omittingEmptySubsequences: false)
        guard parts.count == 3 else { return nil }
        var payload = String(parts[1])
        payload = payload
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let padLength = (4 - payload.count % 4) % 4
        payload += String(repeating: "=", count: padLength)
        guard let data = Data(base64Encoded: payload),
              let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        return dict["nonce"] as? String
    }
}

// MARK: - State

enum State {

    /// Generates a cryptographically random state — 32 bytes from SecRandomCopyBytes,
    /// base64url-encoded (RFC 4648 §5, no padding). Sent in /authorize and verified
    /// on the callback to bind the response to this SDK session (CSRF protection).
    static func generate() -> String {
        randomBase64URL()
    }

    /// Extracts the `state` query parameter value from a callback URL.
    static func value(from url: URL) -> String? {
        URLComponents(url: url, resolvingAgainstBaseURL: false)?
            .queryItems?.first(where: { $0.name == "state" })?.value
    }
}

// MARK: - Private

private func randomBase64URL() -> String {
    var buffer = [UInt8](repeating: 0, count: 32)
    _ = SecRandomCopyBytes(kSecRandomDefault, buffer.count, &buffer)
    return Data(buffer)
        .base64EncodedString()
        .replacingOccurrences(of: "+", with: "-")
        .replacingOccurrences(of: "/", with: "_")
        .replacingOccurrences(of: "=", with: "")
}
