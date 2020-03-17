import XCTest
import Quick
import Nimble
import AnyCodable

@testable import UnserAPIKit

final class RequestBuilderTests: QuickSpec {
    
//    var sut: UnserAPIKit
    
    override func spec() {
        
        it("should set up correct url") {
            expect(self.setupSUT(endpoint: Endpoint.withPath("test"), baseURLString: "https://www.google.com").request.url?.absoluteString) == "https://www.google.com/test"
        }
        
        it("should set up correct url with complex ptah") {
            expect(self.setupSUT(endpoint: Endpoint.withPath("test/subpath"), baseURLString: "https://www.google.com/").request.url?.absoluteString) == "https://www.google.com/test/subpath"
        }
        
        it("should ignore baseURL if endpoint path is an absolute url") {
             expect(self.setupSUT(endpoint: Endpoint.withPathIgnoreBase("https://www.google.com/test/subpath2"), baseURLString: "https://www.fb.com").request.url?.absoluteString) == "https://www.google.com/test/subpath2"
        }
        
        
        it("should ignore baseURL if endpoint specifies that and endpoint path is not absolute") {
             expect(self.setupSUT(endpoint: Endpoint.withPathIgnoreBase("test2/subpath2"), baseURLString: "https://www.fb.com").request.url?.absoluteString) == "test2/subpath2"
        }
        
        it("should set up correct url given a nil baseurl") {
            expect(self.setupSUT(endpoint: Endpoint.withPath("https://www.google.com/test"), baseURLString: nil).request.url?.absoluteString) == "https://www.google.com/test"
        }
    
        it("should throw error with endpoint having invalid path") {
            expect { try self.setupThrowingSUT(endpoint: Endpoint.withPath("\\blabla"), baseURLString: "https://www.google.com")} .to(throwError { (error: Error) in
            expect(error).to(matchError(RequestBuilderError.invalidURL(path: "", baseURL: "")))
                
                if case let RequestBuilderError.invalidURL(path: path, baseURL: baseURL) = error {
                    expect(path) == "\\blabla"
                    expect(baseURL) == "https://www.google.com"
                } else {
                    fail("wrong error/error values encountered")
                }
            })
        }
        
        it("should throw error if baseurl is invalid") {
            expect { try self.setupThrowingSUT(endpoint: Endpoint.withPath("iamvalid"), baseURLString: "iamnot& valid")} .to(throwError { (error: Error) in
            expect(error).to(matchError(RequestBuilderError.invalidURL(path: "", baseURL: "")))
                
                if case let RequestBuilderError.invalidURL(path: path, baseURL: baseURL) = error {
                    expect(path) == "iamvalid"
                    expect(baseURL) == "iamnot& valid"
                } else {
                    fail("wrong error/error values encountered")
                }
            })
        }
        
        it("should set correct httpMethod") {
            expect(self.setupSUT(endpoint: Endpoint.withHttpMethod(.get)).request.httpMethod?.lowercased()) == "get"

            expect(self.setupSUT(endpoint: Endpoint.withHttpMethod(.post)).request.httpMethod?.lowercased()) == "post"
            
            expect(self.setupSUT(endpoint: Endpoint.withHttpMethod( .put)).request.httpMethod?.lowercased()) == "put"
            
        expect(self.setupSUT(endpoint: Endpoint.withHttpMethod( .patch)).request.httpMethod?.lowercased()) == "patch"

            expect(self.setupSUT(endpoint: Endpoint.withHttpMethod( .delete)).request.httpMethod?.lowercased()) == "delete"
        }
        
        it("should default to GET if no http method is passed") {
            expect(self.setupSUT(endpoint: Endpoint.withNothing()).request.httpMethod?.lowercased()) == "get"
        }
        
        it("should set query parameters in url request") {
            expect(self.setupSUT(endpoint: Endpoint.withQueryParameters(["test": "val"])).request.url?.query) == "test=val"
        }
        
        it("should set multiple query parameters in url request") {
            let query = ["test": "val", "test3":"val2"]
            let queryDict = self.setupSUT(endpoint: Endpoint.withQueryParameters(query)).request.url?.query?.extractQueryParamsToDict()
            expect(queryDict) == query
        }
        
        it("should encode the plus sign as well in query parameters") {
            expect(self.setupSUT(endpoint: Endpoint.withQueryParameters(["test": "val+"])).request.url?.query) == "test=val%2B"
        }
        
        it("should set additional headers when given") {
            let headers = ["testHeader": "HeaderValue", "anotherHeader": "anotherValue"]
            
            let actualHeaders = self.setupSUT(endpoint: Endpoint.withHeaders(headers)).request.allHTTPHeaderFields
            expect(actualHeaders?["testHeader"]) == "HeaderValue"
            expect(actualHeaders?["anotherHeader"]) == "anotherValue"
        }
        
        it("should set the content type specified in the endpoint") {
            expect(self.setupSUT(endpoint: Endpoint.withContentType(.application_json)).request.allHTTPHeaderFields?[CONTENT_TYPE_STRING]) == "application/json"
            expect(self.setupSUT(endpoint: Endpoint.withContentType(.multipart_form_data)).request.allHTTPHeaderFields?[CONTENT_TYPE_STRING]) == "multipart/form-data"
            expect(self.setupSUT(endpoint: Endpoint.withContentType(.text_plain)).request.allHTTPHeaderFields?[CONTENT_TYPE_STRING]) == "text/plain"
            expect(self.setupSUT(endpoint: Endpoint.withContentType(.application_x_www_form_urlencoded)).request.allHTTPHeaderFields?[CONTENT_TYPE_STRING]) == "application/x-www-form-urlencoded"
            expect(self.setupSUT(endpoint: Endpoint.withContentType(.null)).request.allHTTPHeaderFields?[CONTENT_TYPE_STRING]) == ""
        }
        
        it("should default the content type to application/json") {
            expect(self.setupSUT(endpoint: Endpoint.withNothing()).request.allHTTPHeaderFields?[CONTENT_TYPE_STRING]) == "application/json"

        }
        
        it("should set the accept type specified in the endpoint") {
            expect(self.setupSUT(endpoint: Endpoint.withAcceptType(.application_json)).request.allHTTPHeaderFields?[ACCEPT_TYPE_STRING]) == "application/json"
            expect(self.setupSUT(endpoint: Endpoint.withAcceptType(.multipart_form_data)).request.allHTTPHeaderFields?[ACCEPT_TYPE_STRING]) == "multipart/form-data"
            expect(self.setupSUT(endpoint: Endpoint.withAcceptType(.text_plain)).request.allHTTPHeaderFields?[ACCEPT_TYPE_STRING]) == "text/plain"
            expect(self.setupSUT(endpoint: Endpoint.withAcceptType(.application_x_www_form_urlencoded)).request.allHTTPHeaderFields?[ACCEPT_TYPE_STRING]) == "application/x-www-form-urlencoded"
            expect(self.setupSUT(endpoint: Endpoint.withAcceptType(.null)).request.allHTTPHeaderFields?[ACCEPT_TYPE_STRING]) == ""
        }
        
        it("should default the accept type to application/json") {
            expect(self.setupSUT(endpoint: Endpoint.withNothing()).request.allHTTPHeaderFields?[ACCEPT_TYPE_STRING]) == "application/json"
        }
        
        it("should set data given in endpoint") {
            let data = "testtest".data(using: .utf8)!
            expect(self.setupSUT(endpoint: Endpoint.withData(data)).request.httpBody) == data
        }
        
        it("should serialize endpoint body to json and add it to request httpBody") {
            let body = ["k1": "v1", "k2": "v2"]
            
            let actualBody = self.setupSUT(endpoint: Endpoint.withBody(body)).request.httpBody?.toDictionary()
            expect(actualBody) == ["k1": "v1", "k2": "v2"]
        }
        
        it("should choose data over jsonBody if both are given") {
            let data = "testtest".data(using: .utf8)!
            let body = ["k1": "v1", "k2": "v2"]

            expect(self.setupSUT(endpoint: Endpoint(path: "bla", data: data, body: body)).request.httpBody) == data
        }
    }
    
    func setupSUT(endpoint: Endpoint) -> RequestBuilder {
        return try! RequestBuilder(endpoint: endpoint, baseURLString: "https://www.google.com")
    }
    
    func setupSUT(endpoint: Endpoint, baseURLString: String?) -> RequestBuilder {
        return try! RequestBuilder(endpoint: endpoint, baseURLString: baseURLString)
    }
    
    func setupThrowingSUT(endpoint: Endpoint, baseURLString: String?) throws -> RequestBuilder {
        return try RequestBuilder(endpoint: endpoint, baseURLString: baseURLString)
    }
}

private extension Endpoint {
    
    static func withNothing() -> Endpoint {
        return Endpoint(path: "test")
    }
    
    static func withHttpMethod(_ method: HttpMethod) -> Endpoint {
        return Endpoint(path: "test", httpMethod: method)
    }
    
    static func withQueryParameters(_ parameters: [String: String]) -> Endpoint {
        return Endpoint(path: "test", queryParameters: parameters)
    }
    
    static func withHeaders(_ headers: [String: String]) -> Endpoint {
        return Endpoint(path: "test", headers: headers)
    }
    
    static func withContentType(_ contentType: ContentType) -> Endpoint {
        return Endpoint(path: "test", contentType: contentType)
    }
    
    static func withAcceptType(_ acceptType: AcceptType) -> Endpoint {
        return Endpoint(path: "test", acceptType: acceptType)
    }
    
    static func withPath(_ path: String) -> Endpoint {
        return Endpoint(path: path)
    }
    
    static func withPathIgnoreBase(_ path: String) -> Endpoint {
        return Endpoint(path: path, resolveAgainstBaseURL: false)
    }
    
    static func withData(_ data: Data) -> Endpoint {
        return Endpoint(path: "whatever", data: data)
    }
    
    static func withBody(_ body: [String: Encodable]) -> Endpoint {
        return Endpoint(path: "whatever", body: body)
    }
    
    
}

private extension String {
    func extractQueryParamsToDict() -> [String: String] {
        let keysVals = self.split(separator: "&").map { query -> [String: String] in
            let splittedQuery = query.split(separator: "=")
            return [String(splittedQuery[0]): String(splittedQuery[1])]
        }.flatMap { $0 }
        return Dictionary(keysVals, uniquingKeysWith: { $1 })
    }
}

private extension Data {
    func toDictionary() -> [String: AnyCodable] {
        return try! JSONDecoder().decode(Dictionary.self, from: self)
    }
}
