//
//  Copyright © Uber Technologies, Inc. All rights reserved.
//


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
