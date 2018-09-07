//
//  AuthenticationProvider.swift
//  UberRides
//
//  Copyright © 2018 Uber Technologies, Inc. All rights reserved.
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
//  OUT OF OR IN CONN

import Foundation

/**
 * Builder for the given loginType's applicable UberAuthenticators.
 */
class AuthenticationProvider {

    let productFlowPriority: [UberAuthenticationProductFlow]
    let scopes: [UberScope]

    /// Returns an AuthenticationProvider.
    ///
    /// - Parameters:
    ///   - scopes: The access scopes for authentication.
    ///   - productFlowPriority: The product flows against which to authenticate, in the order of which Uber products you'd like to use to authenticate the user.
    ///
    ///     For example, you may want to SSO with the UberEats app, but if the app does not exist on the user's device, then try to authenticate with the Uber Rides app instead. In this example you'd call this parameter with [ eats, rides ].
    init(scopes: [UberScope], productFlowPriority: [UberAuthenticationProductFlow]) {
        self.scopes = scopes
        self.productFlowPriority = productFlowPriority
    }

    /// Returns the ordered list of authenticators to use for the given login type.
    func authenticators(for loginType: LoginType) -> [ UberAuthenticating ] {
        return productFlowPriority.map { (authProduct: UberAuthenticationProductFlow) in
            uberAuthenticator(loginType: loginType, authProduct: authProduct)
        }
    }

    private func uberAuthenticator(loginType: LoginType, authProduct: UberAuthenticationProductFlow) -> UberAuthenticating {
        switch loginType {
        case .authorizationCode:
            // Rides and Eats temporarily share the same authorization code flow
            return AuthorizationCodeGrantAuthenticator(scopes: scopes)
        case .implicit:
            // Rides and Eats temporarily share the same implicit grant code flow
            return ImplicitGrantAuthenticator(scopes: scopes)
        case .native:
            switch authProduct.uberProductType {
            case .rides:
                return RidesNativeAuthenticator(scopes: scopes)
            case .eats:
                return EatsNativeAuthenticator(scopes: scopes)
            }
        }
    }
}
