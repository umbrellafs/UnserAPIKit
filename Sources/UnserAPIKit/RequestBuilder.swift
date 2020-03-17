//
//  File.swift
//  
//
//  Created by Abdulhaq Emhemmed on 3/17/20.
//

import Foundation


enum HttpMethod {
    case get
    case post
    case put
    case patch
    case delete
    
    func value() -> String {
        switch self {
        case .get:
            return "GET"
        case .post:
            return "POST"
        case .put:
            return "PUT"
        case .patch:
            return "PATCH"
        case .delete:
            return "DELETE"
        }
    }
}

enum MIMEType {
  case application_json, multipart_form_data, text_plain, application_x_www_form_urlencoded, null
  func value() -> String {
    switch self {
    case .application_json:
      return "application/json"
    case .multipart_form_data:
      return "multipart/form-data"
    case .text_plain:
      return "text/plain"
    case .application_x_www_form_urlencoded:
      return "application/x-www-form-urlencoded"
    case .null:
      return ""
    }
  }
}

var CONTENT_TYPE_STRING = "Content-Type"
var ACCEPT_TYPE_STRING = "Accept"

typealias ContentType = MIMEType
typealias AcceptType = MIMEType

typealias Headers = [String: String]
typealias QueryParameters = [String: String]

struct Endpoint {
    var path: String
    var httpMethod: HttpMethod?
    var queryParameters: QueryParameters?
    var headers: Headers?
    var contentType: ContentType
    var acceptType: AcceptType
    var resolveAgainstBaseURL: Bool
    var data: Data?
    var body: [String: Encodable]?
    
    init(path: String, httpMethod: HttpMethod? = nil, queryParameters: QueryParameters? = nil, headers: Headers? = nil, contentType: ContentType = .application_json, acceptType: AcceptType = .application_json, data: Data? = nil, body: [String: Encodable]? = nil, resolveAgainstBaseURL: Bool = true) {
        self.path = path
        self.httpMethod = httpMethod
        self.queryParameters = queryParameters
        self.headers = headers
        self.contentType = contentType
        self.acceptType = acceptType
        self.data = data
        self.body = body
        self.resolveAgainstBaseURL = resolveAgainstBaseURL
    }
}

enum RequestBuilderError: Error {
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
                throw RequestBuilderError.invalidURL(path: self.endpoint.path, baseURL: baseURLString)
            }
            relativeURL = u
        }
                
        guard let enpointURL = URL(string: self.endpoint.path, relativeTo: relativeURL), let components = URLComponents(url: enpointURL, resolvingAgainstBaseURL: self.endpoint.resolveAgainstBaseURL) else {
            throw RequestBuilderError.invalidURL(path: self.endpoint.path, baseURL: self.baseURLString)
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
