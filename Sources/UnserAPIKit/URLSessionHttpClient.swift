//
//  File.swift
//  
//
//  Created by Abdulhaq Emhemmed on 3/18/20.
//

import Foundation

public protocol HttpClient {
    typealias Result = Swift.Result<(Data?, HTTPURLResponse), Error>
    func request(endpoint: Endpoint, networkRequest: NetworkRequest, completion: @escaping (Result) -> Void)
}

final public class URLSessionHttpClient: HttpClient {
    
    private var baseURL: String
    private var urlSession: URLSession
    
    public init(baseURL: String, urlSession: URLSession) {
        self.baseURL = baseURL
        self.urlSession = urlSession
    }
    
    private struct UnexpectedValuesRepresentation: Error {}
    
    public func request(endpoint: Endpoint, networkRequest: NetworkRequest, completion: @escaping (HttpClient.Result) -> Void) {
        
        do {
            let requestBuilder = try RequestBuilder(endpoint: endpoint, baseURLString: self.baseURL)
            
            let dataTask = self.urlSession.dataTask(with: requestBuilder.request) { data, response, error in
                completion(HttpClient.Result {
                    if let error = error {
                        throw error
                    } else if let httpResponse = response as? HTTPURLResponse {
                        return (data, httpResponse)
                    } else {
                        throw UnexpectedValuesRepresentation()
                    }
                })
            }
            networkRequest.start(dataTask)
        } catch let e {
            completion(.failure(e))
        }
        
  
    }
}
