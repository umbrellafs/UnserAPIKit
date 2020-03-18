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


class NetworkRequest {
    
    private(set) var task: URLSessionTaskProtocol?
    
    func start(_ task: URLSessionTaskProtocol) {
        precondition(self.task == nil)
        self.task = task
        task.resume()
    }
    
    func cancel() {
        self.task?.cancel()
        self.task = nil
    }
}
