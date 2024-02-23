//
//  Copyright © Uber Technologies, Inc. All rights reserved.
//


import Foundation

public protocol ClientProvider {
    
    /// The OAuth2 Authorization Code returned by the provider
    var authorizationCode: String? { get }
    
    var accessToken: String? { get }
    
    var refreshToken: String? { get }
    
    var tokenType: String? { get }
    
    var expiresIn: Int? { get }
    
    var scope: [String]? { get }
}

public struct Client: ClientProvider, Equatable {
    
    // MARK: Properties
    
    public let authorizationCode: String?
    
    public let accessToken: String?
    
    public let refreshToken: String?
    
    public let tokenType: String?
    
    public let expiresIn: Int?
    
    public let scope: [String]?
    
    // MARK: Initializers
    
    public init(authorizationCode: String? = nil,
                accessToken: String? = nil,
                refreshToken: String? = nil,
                tokenType: String? = nil,
                expiresIn: Int? = nil,
                scope: [String]? = nil) {
        self.authorizationCode = authorizationCode
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.tokenType = tokenType
        self.expiresIn = expiresIn
        self.scope = scope
    }
}
