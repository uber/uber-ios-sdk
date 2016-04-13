//
//  Request.swift
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

/// Class to create and execute NSURLRequests.
class Request: NSObject {
    let session: NSURLSession?
    let endpoint: UberAPI
    let urlRequest: NSMutableURLRequest
    let bearerToken: NSString?
    
    /**
     Initialize a request object.
     
     - parameter hostURL:     Host URL string for API.
     - parameter session:     NSURLSession to execute request with.
     - parameter endpoint:    UberAPI conforming endpoint.
     */
    init(session: NSURLSession?, endpoint: UberAPI, bearerToken: NSString? = nil) {
        self.session = session
        self.endpoint = endpoint
        self.urlRequest = NSMutableURLRequest()
        self.bearerToken = bearerToken
    }
    
    /**
     Creates a URL based off the endpoint requested. Function asserts for valid URL.
     
     - returns: constructed NSURL or nil if construction failed.
     */
    func requestURL() -> NSURL? {
        let components = NSURLComponents(string: endpoint.host)!
        components.path = endpoint.path
        components.queryItems = endpoint.query
        
        return components.URL
    }
    
    /**
     Adds HTTP Headers to the request.
     */
    private func addHeaders() {
        if let token = bearerToken {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
    }
    
    private func addGzip() {
        urlRequest.setValue("gzip, deflate", forHTTPHeaderField: "Accept-Encoding")
    }
    
    /**
     Prepares the NSURLRequest by adding necessary fields.
     */
    func prepare() {
        urlRequest.URL = requestURL()
        urlRequest.HTTPMethod = endpoint.HTTPMethod.rawValue
        addHeaders()
        addGzip()
    }
}
