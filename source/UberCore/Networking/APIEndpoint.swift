//
//  APIEndpoint.swift
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
 *  Protocol for all endpoints to conform to.
 */
public protocol APIEndpoint {
    var body: Data? { get }
    var headers: [String: String]? { get }
    var host: String { get}
    var method: UberHTTPMethod { get }
    var path: String { get }
    var query: [URLQueryItem] { get }
}

public extension APIEndpoint {
    var body: Data? {
        return nil
    }

    var headers: [String: String]? {
        return nil
    }

    var host: String {
        if Configuration.shared.isSandbox {
            return "https://sandbox-api.uber.com"
        } else {
            return "https://api.uber.com"
        }
    }

    var url: URL {
        var components = URLComponents(string: host)
        components?.path = path
        components?.queryItems = query
        guard let url = components?.url else {
            preconditionFailure("Could not generate URL from endpoint object. ")
        }
        return url
    }

    /**
     Helper function to build array of NSURLQueryItems. A key-value pair with an empty string value is ignored.

     - parameter queries: tuples of key-value pairs
     - returns: an array of NSURLQueryItems
     */
    func queryBuilder(_ queries: (name: String, value: String)...) -> [URLQueryItem] {
        var queryItems = [URLQueryItem]()
        for query in queries {
            if query.name.isEmpty || query.value.isEmpty {
                continue
            }
            queryItems.append(URLQueryItem(name: query.name, value: query.value))
        }
        return queryItems
    }
}

/**
 Enum for UberHTTPMethods
 */
public enum UberHTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}
