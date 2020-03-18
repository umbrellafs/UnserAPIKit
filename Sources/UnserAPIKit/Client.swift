//
//  File.swift
//  
//
//  Created by Abdulhaq Emhemmed on 3/18/20.
//

import Foundation

public protocol ClientProtocol {
    func request(endpoint: Endpoint, networkRequest: NetworkRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)
}

final public class Client: ClientProtocol {
    
    private var baseURL: String
    private var urlSession: URLSession
    
    public init(baseURL: String, urlSession: URLSession) {
        self.baseURL = baseURL
        self.urlSession = urlSession
    }
    
    public func request(endpoint: Endpoint, networkRequest: NetworkRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        
        do {
            let requestBuilder = try RequestBuilder(endpoint: endpoint, baseURLString: self.baseURL)
            
            let dataTask = self.urlSession.dataTask(with: requestBuilder.request, completionHandler: completionHandler)
            networkRequest.start(dataTask)
        } catch let e {
            completionHandler(nil, nil, e)
        }
        
  
    }
}
