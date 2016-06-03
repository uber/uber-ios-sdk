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

/**
*  Struct that packages the response from an executed NSURLRequest.
*/
@objc(UBSDKResponse) public class Response: NSObject {
    /// String representing JSON response data.
    public var data: NSData?
    
    /// HTTP status code of response.
    public var statusCode: Int
    
    /// Response metadata.
    public var response: NSHTTPURLResponse?
    
    /// NSError representing an optional error.
    public var error: RidesError?
    
    /**
     Initialize a Response object.
     
     - parameter data:     Data returned from server.
     - parameter response: Provides response metadata, such as HTTP headers and status code.
     - parameter error:    Indicates why the request failed, or nil if the request was successful.
     */
    init(data: NSData?, statusCode: Int, response: NSHTTPURLResponse?, error: RidesError?) {
        self.data = data
        self.response = response
        self.statusCode = statusCode
        self.error = error
    }
    
    /**
     - returns: string representation of JSON data.
     */
    func toJSONString() -> NSString {
        guard let data = data else {
            return ""
        }
        
        return NSString(data: data, encoding: NSUTF8StringEncoding)!
    }
}

/// Class to create and execute NSURLRequests.
class Request: NSObject {
    let session: NSURLSession?
    let endpoint: UberAPI
    let urlRequest: NSMutableURLRequest
    let serverToken: NSString?
    let bearerToken: NSString?
    
    /**
     Initialize a request object.
     
     - parameter hostURL:     Host URL string for API.
     - parameter session:     NSURLSession to execute request with.
     - parameter endpoint:    UberAPI conforming endpoint.
     - parameter serverToken: Developer's server token.
     */
    init(session: NSURLSession?, endpoint: UberAPI, serverToken: NSString? = nil, bearerToken: NSString? = nil) {
        self.session = session
        self.endpoint = endpoint
        self.urlRequest = NSMutableURLRequest()
        self.serverToken = serverToken
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
        urlRequest.setValue("gzip, deflate", forHTTPHeaderField: "Accept-Encoding")
        if let token = bearerToken {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: Header.Authorization.rawValue)
        } else if let token = serverToken {
            urlRequest.setValue("Token \(token)", forHTTPHeaderField: Header.Authorization.rawValue)
        }
        if let headers = endpoint.headers {
            for (header,value) in headers {
                urlRequest.setValue(value, forHTTPHeaderField: header)
            }
        }
    }
    
    /**
     Prepares the NSURLRequest by adding necessary fields.
     */
    func prepare() {
        urlRequest.URL = requestURL()
        urlRequest.HTTPMethod = endpoint.method.rawValue
        urlRequest.HTTPBody = endpoint.body
        addHeaders()
    }
    
    /**
     Performs all steps to execute request (construct URL, add headers, etc).
     
     - parameter completion: completion handler for returned Response.
     */
    func execute(completion: (response: Response) -> Void) {
        guard let session = session else {
            return
        }
        
        prepare()
        let task = session.dataTaskWithRequest(urlRequest, completionHandler: {
            (data, response, error) in
            let httpResponse: NSHTTPURLResponse? = response as? NSHTTPURLResponse
            var statusCode: Int = 0
            var ridesError: RidesError?
            
            // Handle HTTP errors.
            errorCheck: if httpResponse != nil {
                statusCode = httpResponse!.statusCode
                
                if statusCode <= 299 {
                    break errorCheck
                }
                
                let jsonString = NSString(data: data!, encoding: NSUTF8StringEncoding)!
                if statusCode >= 400 && statusCode <= 499 {
                    ridesError = ModelMapper<RidesClientError>().mapFromJSON(jsonString)
                } else if (statusCode >= 500 && statusCode <= 599) {
                    ridesError = ModelMapper<RidesServerError>().mapFromJSON(jsonString)
                } else {
                    ridesError = ModelMapper<RidesUnknownError>().mapFromJSON(jsonString)
                }
                
                ridesError?.status = statusCode
            }
            
            // Any other errors.
            if response == nil || error != nil {
                ridesError = RidesUnknownError()
                
                if let error = error {
                    ridesError!.title = error.domain
                    ridesError!.status = error.code
                } else {
                    ridesError!.title = "Request could not complete"
                    ridesError!.code = "request_error"
                }
            }
            
            let ridesResponse = Response(data: data, statusCode: statusCode, response: httpResponse, error: ridesError)
            completion(response: ridesResponse)
        })
        task.resume()
    }
    
    /**
     *  Cancel data tasks if needed.
     */
    func cancelTasks() {
        guard let session = session else {
            return
        }
        
        session.getTasksWithCompletionHandler({ data, upload, download in
            for task in data {
                task.cancel()
            }
        })
    }
}
