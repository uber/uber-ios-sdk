//
//  UberAuthenticatingProtocol.swift
//  UberRides
//
//  Copyright © 2016 Uber Technologies, Inc. All rights reserved.
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

import UIKit

public typealias AuthenticationCompletionHandler = (_ accessToken: AccessToken?, _ error: NSError?) -> Void

/**
 *  Protocol to conform to for defining an authorization flow.
 */
protocol UberAuthenticating {
    /// Scopes to request during login
    var scopes: [UberScope] { get }

    /**
     Get URL to begin login process.
     */
    var authorizationURL: URL { get }

    /**
     Handles a request from the web view to see if it's a redirect.
     Redirects are handled differently for different authorization types.
     
     - parameter url: the URL
     - parameter competion: the completion handler. Completes with an access token if recieved, or an error if not. 
     */
    func consumeResponse(url: URL, completion: AuthenticationCompletionHandler?)
}
