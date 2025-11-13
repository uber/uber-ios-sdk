//
//  NetworkProvider.swift
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

/// @mockable
protocol NetworkProviding {
    @available(*, deprecated, message: "This method is deprecated. Use the async method instead.")
    func execute<R: NetworkRequest>(request: R, completion: @escaping (Result<R.Response, UberAuthError>) -> ())
    func execute<R: NetworkRequest>(request: R) async throws -> R.Response
}

final class NetworkProvider: NetworkProviding {

    private let baseUrl: String
    private let session: URLSession
    private let decoder = JSONDecoder()
    
    init(baseUrl: String) {
        self.baseUrl = baseUrl
        self.session = URLSession(configuration: .default)
    }
    @available(*, deprecated, message: "This method is deprecated. Use the async method instead.")
    func execute<R: NetworkRequest>(request: R, completion: @escaping (Result<R.Response, UberAuthError>) -> ()) {
        guard let urlRequest = request.urlRequest(baseUrl: baseUrl) else {
            completion(.failure(UberAuthError.invalidRequest("")))
            return
        }
        
        let dataTask = session
            .dataTask(
                with: urlRequest,
                completionHandler: { data, response, error in
                    if let error {
                        completion(.failure(.other(error)))
                        return
                    }
                    
                    guard let data,
                            let response = response as? HTTPURLResponse else {
                        completion(.failure(UberAuthError.oAuth(.unsupportedResponseType)))
                        return
                    }
                    
                    if let error = UberAuthError(response) {
                        completion(.failure(error))
                        return
                    }
                    
                    do {
                        let decodedResponse = try self.decoder.decode(R.Response.self, from: data)
                        completion(.success(decodedResponse))
                    } catch {
                        completion(.failure(UberAuthError.serviceError))
                    }
                }
            )
        
        dataTask.resume()
    }
    
    func execute<R: NetworkRequest>(request: R) async throws -> R.Response {
        guard let urlRequest = request.urlRequest(baseUrl: baseUrl) else {
            throw UberAuthError.invalidRequest("")
        }
        
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: urlRequest)
        } catch {
            throw UberAuthError.other(error)
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw UberAuthError.oAuth(.unsupportedResponseType)
        }
        
        if let error = UberAuthError(httpResponse) {
            throw error
        }
        
        do {
            let decodedResponse = try decoder.decode(R.Response.self, from: data)
            return decodedResponse
        } catch {
            throw UberAuthError.serviceError
        }
    }
}

