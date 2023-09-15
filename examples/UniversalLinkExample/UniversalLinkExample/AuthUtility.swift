//
//  Copyright © Uber Technologies, Inc. All rights reserved.
//


import CommonCrypto
import SwiftUI

final class AuthUtility: ObservableObject {
    
    @Published
    var appName: String
    
    @Published
    var clientId: String
    
    @Published
    var redirectURI: String
    
    @Published
    var responseType: String = "code"
    
    @Published
    var codeChallenge: String
    
    @Published
    var codeChallengeMethod: String = "S256"
    
    var codeVerifier: String {
        pkce.codeVerifier
    }
    
    private let pkce: PKCE
    
    init() {
        self.appName = Self.defaultValue(for: "UberDisplayName")
        self.clientId = Self.defaultValue(for: "UberClientID")
        self.redirectURI = Self.defaultValue(for: "UberRedirectURI")
        
        let pkce = PKCE()
        self.codeChallenge = pkce.codeChallenge
        self.pkce = pkce
    }
    
    /// Validates that all required parameters have been supplied
    var canSubmit: Bool {
        !clientId.isEmpty && !redirectURI.isEmpty
    }
    
    /// Opens the authorize url
    func openURL() {
        UIApplication.shared.open(url)
    }
    
    /// Constructs the /authorize url with the provided parameters
    var url: URL {
        var components = URLComponents(string: "https://auth.uber.com/oauth/v2/universal/authorize")
        components?.queryItems = [
            Parameter.clientID.identifier: clientId,
            Parameter.redirectURI.identifier: redirectURI,
            Parameter.resposeType.identifier: responseType,
            Parameter.codeChallenge.identifier: codeChallenge,
            Parameter.codeChallengeMethod.identifier: codeChallengeMethod
        ]
        .map { URLQueryItem(name: $0.key, value: $0.value) }
        .sorted(by: { $0.name < $1.name })
        
        return components?.url ?? URL(filePath: "")
    }
    
    func getAuthToken(withAuthCode code: String) async -> String {
        var components = URLComponents(string: "https://auth.uber.com/oauth/v2/token/")
        components?.queryItems = [
            Parameter.clientID.identifier: clientId,
            Parameter.redirectURI.identifier: redirectURI,
            "grant_type": "authorization_code",
            "code": code,
            "code_verifier": pkce.codeVerifier
        ]
        .map { URLQueryItem(name: $0.key, value: $0.value) }
        
        guard let url = components?.url else {
            return "Error: Failed to create URL"
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        do {
            let (data, _) = try await URLSession(configuration: .default)
                .data(for: request)
            
            guard let token = String(data: data, encoding: .utf8) else {
                return "Error: Failed to decode response"
            }
            
            return token
        }
        catch {
            return "Error: /oauth/v2/token request failed"
        }
    }
    
    // MARK: - Private
    
    /// Generates a new unique identifier to be passed into the /oauth/v2/token endpoint as the `state` parameter
    /// - Returns: A new state token identifier
    private static func codeChallenge() -> String {
        UUID().uuidString
    }
    
    // MARK: - Helpers
    
    private static func defaultValue(for key: String) -> String {
        (plistValues.object(forKey: key) as? String) ?? ""
    }
    
    private static let plistValues: NSDictionary = {
        guard let path = Bundle.main.path(forResource: "Info", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) else {
            return [:]
        }
        return dict
    }()
}


public struct PKCE {

    public let codeVerifier: String
    public let codeChallenge: String

    public init() {
        let pkce = PKCE.generatePKCE()
        self.codeVerifier = pkce.codeVerifier
        self.codeChallenge = pkce.codeChallenge
    }

    init(codeVerifier: String, codeChallenge: String) {
        self.codeChallenge = codeChallenge
        self.codeVerifier = codeVerifier
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
