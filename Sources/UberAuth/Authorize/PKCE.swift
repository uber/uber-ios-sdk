//
//  PKCE.swift
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


import CommonCrypto
import Foundation

public struct PKCE {

    public let codeVerifier: String
    public let codeChallenge: String

    public init() {
        let pkce = PKCE.generatePKCE()
        self.codeVerifier = pkce.codeVerifier
        self.codeChallenge = pkce.codeChallenge
    }

    static func generatePKCE() -> (codeChallenge: String, codeVerifier: String) {
        let charDictCodeVerifer: [Character: Character] = ["+": "-", "/": "-", "=": "-"]
        let charDictCodeChallenge: [Character: Character] = ["+": "-", "/": "_", "=": " "]

        var buffer1 = [UInt8](repeating: 0, count: 64)
        _ = SecRandomCopyBytes(kSecRandomDefault, buffer1.count, &buffer1)
        let codeVerifierData = Data(buffer1)
        let codeVerifier = codeVerifierData.convertToStringByReplacingCharacters(dict: charDictCodeVerifer)

        guard let codeVerifierBytes = codeVerifier.data(using: .ascii) else { return ("", "") }
        var buffer2 = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        codeVerifierBytes.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(codeVerifierBytes.count), &buffer2)
        }

        let codeChallengeData = Data(buffer2)
        let codeChallenge = codeChallengeData.convertToStringByReplacingCharacters(dict: charDictCodeChallenge)
        return (codeChallenge, codeVerifier)

    }
}

fileprivate extension Data {
    func convertToStringByReplacingCharacters(dict: [Character: Character]) -> String {
        let string = self.base64EncodedString()
        let stringArray: [Character] = string.map {
            guard let val = dict[$0] else {
                return $0
            }
            return val
        }
        return String(stringArray).trimmingCharacters(in: .whitespaces)
    }
}
