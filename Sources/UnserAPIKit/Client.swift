//
//  File.swift
//  
//
//  Created by Abdulhaq Emhemmed on 3/18/20.
//

import Foundation



final class Client {
    
    private var baseURL: String
    private var urlSession: URLSession
    
    init(baseURL: String, urlSession: URLSession) {
        self.baseURL = baseURL
        self.urlSession = urlSession
    }
    
    func request(endpoint: Endpoint, networkRequest: NetworkRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) throws {
        
        do {
            let requestBuilder = try RequestBuilder(endpoint: endpoint, baseURLString: self.baseURL)
            
            let dataTask = self.urlSession.dataTask(with: requestBuilder.request, completionHandler: completionHandler)
            networkRequest.start(dataTask)
        } catch let e {
            throw e
        }
        
  
    }
}
