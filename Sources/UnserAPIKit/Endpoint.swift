//
//  File.swift
//  
//
//  Created by Abdulhaq Emhemmed on 3/18/20.
//

import Foundation

public enum HttpMethod {
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

public enum MIMEType {
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

public typealias ContentType = MIMEType
public typealias AcceptType = MIMEType

public typealias Headers = [String: String]
public typealias QueryParameters = [String: String]

public struct Endpoint {
    public var path: String
    public var httpMethod: HttpMethod?
    public var queryParameters: QueryParameters?
    public var headers: Headers?
    public var contentType: ContentType
    public var acceptType: AcceptType
    public var resolveAgainstBaseURL: Bool
    public var data: Data?
    public var body: [String: Encodable]?
    
    public init(path: String, httpMethod: HttpMethod = .get, queryParameters: QueryParameters? = nil, headers: Headers? = nil, contentType: ContentType = .application_json, acceptType: AcceptType = .application_json, data: Data? = nil, body: [String: Encodable]? = nil, resolveAgainstBaseURL: Bool = true) {
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
