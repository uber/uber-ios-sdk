//
//  Copyright © Uber Technologies, Inc. All rights reserved.
//


import Foundation

/// @mockable
protocol NetworkProviding {
    func execute<R: NetworkRequest>(request: R, completion: @escaping (Result<R.Response, UberAuthError>) -> ())
}

final class NetworkProvider: NetworkProviding {

    private let baseUrl: String
    private let session: URLSession
    private let decoder = JSONDecoder()
    
    init(baseUrl: String) {
        self.baseUrl = baseUrl
        self.session = URLSession(configuration: .default)
    }
    
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
}
