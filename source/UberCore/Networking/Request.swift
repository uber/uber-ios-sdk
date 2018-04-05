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
    @objc public var data: Data?
    
    /// HTTP status code of response.
    @objc public var statusCode: Int
    
    /// Response metadata.
    @objc public var response: HTTPURLResponse?
    
    /// NSError representing an optional error.
    @objc public var error: UberError?
    
    /**
     Initialize a Response object.
     
     - parameter data:     Data returned from server.
     - parameter response: Provides response metadata, such as HTTP headers and status code.
     - parameter error:    Indicates why the request failed, or nil if the request was successful.
     */
    @objc public init(data: Data?, statusCode: Int, response: HTTPURLResponse?, error: UberError?) {
        self.data = data
        self.response = response
        self.statusCode = statusCode
        self.error = error
    }
    
    /**
     - returns: string representation of JSON data.
     */
    func toJSONString() -> String {
        guard let data = data else {
            return ""
        }
        
        return String(data: data, encoding: String.Encoding.utf8)!
    }
}

/// Class to create and execute NSURLRequests.
public class Request {
    let session: URLSession?
    let endpoint: APIEndpoint
    private(set) public var urlRequest: URLRequest
    let serverToken: String?
    let bearerToken: String?
    
    /**
     Initialize a request object.
     
     - parameter hostURL:     Host URL string for API.
     - parameter session:     NSURLSession to execute request with.
     - parameter endpoint:    UberAPI conforming endpoint.
     - parameter serverToken: Developer's server token.
     */
    public init?(session: URLSession?, endpoint: APIEndpoint, serverToken: String? = nil, bearerToken: String? = nil) {
        guard var components = URLComponents(string: endpoint.host) else {
            return nil
        }
        components.path = endpoint.path
        components.queryItems = endpoint.query

        guard let url = components.url else {
            return nil
        }
        urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = endpoint.method.rawValue
        urlRequest.httpBody = endpoint.body

        self.session = session
        self.endpoint = endpoint
        self.serverToken = serverToken
        self.bearerToken = bearerToken
    }
    
    /**
     Adds HTTP Headers to the request.
     */
    private func addHeaders() {
        urlRequest.setValue("gzip, deflate", forHTTPHeaderField: "Accept-Encoding")

        if let versionNumber = Bundle(for: type(of: self)).object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            urlRequest.setValue("iOS Rides SDK v\(versionNumber)", forHTTPHeaderField: "X-Uber-User-Agent")
        }
        if let token = bearerToken {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else if let token = serverToken {
            urlRequest.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
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
    public func prepare() {
        addHeaders()
    }
    
    /**
     Performs all steps to execute request (construct URL, add headers, etc).
     
     - parameter completion: completion handler for returned Response.
     */
    public func execute(_ completion: @escaping (_ response: Response) -> Void) {
        guard let session = session else {
            return
        }
        
        addHeaders()
        let task = session.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            let httpResponse: HTTPURLResponse? = response as? HTTPURLResponse
            var statusCode: Int = 0
            var ridesError: UberError?
            
            // Handle HTTP errors.
            errorCheck: if httpResponse != nil {
                statusCode = httpResponse!.statusCode
                
                if statusCode <= 299 {
                    break errorCheck
                }
                
                if statusCode >= 400 && statusCode <= 499 {
                    ridesError = try? JSONDecoder.uberDecoder.decode(UberClientError.self, from: data!)
                } else if (statusCode >= 500 && statusCode <= 599) {
                    ridesError = try? JSONDecoder.uberDecoder.decode(UberServerError.self, from: data!)
                } else {
                    ridesError = try? JSONDecoder.uberDecoder.decode(UberUnknownError.self, from: data!)
                }
                
                ridesError?.status = statusCode
            }
            
            // Any other errors.
            if response == nil || error != nil {
                if let error = error as NSError? {
                    ridesError = UberUnknownError(status: error.code, code: nil, title: error.domain)
                } else {
                    ridesError = UberUnknownError(status: -1, code: "request_error", title: "Request could not complete")
                }
            }
          
            let ridesResponse = Response(data: data, statusCode: statusCode, response: httpResponse, error: ridesError)
            completion(ridesResponse)
        })
        task.resume()
    }
    
    /**
     *  Cancel data tasks if needed.
     */
    public func cancelTasks() {
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
