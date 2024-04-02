//
//  Copyright © Uber Technologies, Inc. All rights reserved.
//


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
