//
//  NetworkRequest.swift
//  UberAuth
//
//  Copyright © 2024 Uber Technologies, Inc. All rights reserved.
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


import Foundation

protocol NetworkRequest {

    associatedtype Response: Codable
    
    var body: [String: String]? { get }
    var contentType: String? { get }
    var headers: [String: String]? { get }
    var host: String? { get }
    var method: HTTPMethod { get }
    var parameters: [String: String]? { get }
    var path: String { get }
    var scheme: String? { get }
}

extension NetworkRequest {
    
    var contentType: String? { nil }
    var body: [String: String]? { nil }
    var headers: [String: String]? { nil }
    var host: String? { nil }
    var method: HTTPMethod { .get }
    var parameters: [String: String]? { nil }
    var scheme: String? { nil }
}

extension NetworkRequest {
    
    func url(baseUrl: String) -> URL? {
        urlRequest(baseUrl: baseUrl)?.url
    }
    
    func urlRequest(baseUrl: String) -> URLRequest? {
        guard var components = URLComponents(string: baseUrl) else {
            return nil
        }
        
        if let host {
            components.host = host
        }
        if let scheme {
            components.scheme = scheme
        }
        components.path = path
        components.queryItems = parameters?.map { (name, value) in
            URLQueryItem(name: name, value: value)
        }
        
        guard let url = components.url else {
            return nil
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        
        // Headers
        urlRequest.allHTTPHeaderFields = {
            let defaultHeaders = [
                "Accept-Encoding": "gzip, deflate",
                "Content-Type": contentType
            ]
            .compactMapValues { $0 }
            
            return defaultHeaders
                .merging(
                    headers ?? [:],
                    uniquingKeysWith: { h1, h2 in h1 }
                )
        }()
        
        // Body
        urlRequest.httpBody = {
            var components = URLComponents()
            components.queryItems = body?.map { URLQueryItem(name: $0.key, value: $0.value) }
            return components.query?.data(using: .utf8)
        }()
        
        return urlRequest
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}
