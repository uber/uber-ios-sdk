//
//  DeeplinkingProtocol.swift
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

/**
 *  Protocol for defining a deeplink that can be executed to open an external app
 */
@objc(UBSDKDeeplinking) public protocol Deeplinking {
    
    /// The deeplink scheme to use, where a deeplink takes the form scheme://domain/path?query
    var scheme: String { get }
    
    /// The domain of the deeplink, where a deeplink takes the form scheme://domain/path?query
    var domain: String { get }
    
    /// The path of the deeplink, where a deeplink takes the form scheme://domain/path?query
    var path: String? { get }
    
    /// The query parameter items for the deeplink, where a deeplink takes the form scheme://domain/path?query
    var queryItems: [URLQueryItem]? { get }
    
    /// The deeplink URL that the deeplink will execute
    var deeplinkURL: URL { get }
    
    /**
     Execute a deeplink to launch into an external app
     
     - returns: true if the deeplink was executed, false otherwise.
     */
    
    /**
     Execute a deeplink to launch into an external app
     
     - parameter completion: The completion block to execute once the deeplink has
     executed. Passes in True if the url was successfully opened, false otherwise.
     */
    @objc func execute(_ completion: ((NSError?) -> ())?)
}
