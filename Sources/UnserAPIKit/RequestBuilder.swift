//
//  File.swift
//  
//
//  Created by Abdulhaq Emhemmed on 3/17/20.
//

import Foundation

enum UnserAPIKitError: Error {
    case invalidURL(path: String, baseURL: String?)
}

final class RequestBuilder {
    private var baseURLString: String?
    private var endpoint: Endpoint
    
    private var urlComponent: URLComponents!
    private var url: URL!
    
    var request: URLRequest!

    init(endpoint: Endpoint, baseURLString: String?) throws {
        self.endpoint = endpoint
        self.baseURLString = baseURLString
        try self.buildURL()
        self.buildRequest()
    }
    
    // MARK: - URL Building
    private func buildURL() throws {
        
        var relativeURL: URL? = nil
                
        if let baseURLString = self.baseURLString {
            guard let u = URL(string: baseURLString) else {
                throw UnserAPIKitError.invalidURL(path: self.endpoint.path, baseURL: baseURLString)
            }
            relativeURL = u
        }
                
        guard let enpointURL = URL(string: self.endpoint.path, relativeTo: relativeURL), let components = URLComponents(url: enpointURL, resolvingAgainstBaseURL: self.endpoint.resolveAgainstBaseURL) else {
            throw UnserAPIKitError.invalidURL(path: self.endpoint.path, baseURL: self.baseURLString)
        }
        
        self.urlComponent = components
        self.setupQueryParameters()
        self.url = self.urlComponent.url!
    }
    
    private func setupQueryParameters() {
        self.urlComponent.queryItems = self.endpoint.queryParameters?.map {
            (key, val) in
            return URLQueryItem(name: String(key), value: String(val))
        }
        self.urlComponent.percentEncodedQuery = self.urlComponent.percentEncodedQuery?
            .replacingOccurrences(of: "+", with: "%2B")
    }
    
    // MARK: - Request building
    
    private func buildRequest() {
        self.request = URLRequest(url: self.url)
        self.setHttpMethod()
        self.setupContentType()
        self.setupAcceptType()
        self.setupHeaders()
        self.setupData()
    }
    
    private func setHttpMethod() {
        self.request.httpMethod = endpoint.httpMethod?.value() ?? HttpMethod.get.value()
    }
    
    private func setupContentType() {
    self.request.setValue(self.endpoint.contentType.value(), forHTTPHeaderField: CONTENT_TYPE_STRING)
    }
    
    private func setupAcceptType() {
    self.request.setValue(self.endpoint.acceptType.value(), forHTTPHeaderField: ACCEPT_TYPE_STRING)
    }
    
    private func setupHeaders() {
        for (key, val) in self.endpoint.headers ?? [:] {
            self.request.setValue(val, forHTTPHeaderField: key)
        }
    }
    
    private func setupData() {
        if let data = self.endpoint.data {
            self.request.httpBody = data
        } else if let body = self.endpoint.body {
            self.request.httpBody = try! JSONSerialization.data(withJSONObject: body, options: [])
        }
    }
}
