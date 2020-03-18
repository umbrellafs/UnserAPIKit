//
//  File.swift
//  
//
//  Created by Abdulhaq Emhemmed on 3/18/20.
//

import Foundation

protocol URLSessionTaskProtocol: class {
    func resume()
    func cancel()
}

extension URLSessionTask: URLSessionTaskProtocol {}


public class NetworkRequest {
    
    private(set) var task: URLSessionTaskProtocol?
    
    public init() {
    }
    
    func start(_ task: URLSessionTaskProtocol) {
        precondition(self.task == nil)
        self.task = task
        task.resume()
    }
    
    public func cancel() {
        self.task?.cancel()
        self.task = nil
    }
}
