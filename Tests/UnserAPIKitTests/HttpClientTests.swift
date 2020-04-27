//
//  File.swift
//  
//
//  Created by Abdulhaq Emhemmed on 3/18/20.
//

import Foundation
import XCTest
import Quick
import QuickSpecBase
import Nimble

@testable import UnserAPIKit

final class ClientTests: QuickSpec {
    
    var sut: URLSessionHttpClient!
    var urlSession: URLSession!
    
    
    override func spec() {
        
        beforeEach {
            URLProtocol.registerClass(URLProtocolMock.self)
            let config = URLSessionConfiguration.ephemeral
            config.protocolClasses = [URLProtocolMock.self]
            self.urlSession = URLSession(configuration: config)
            self.sut = URLSessionHttpClient(baseURL: "https://www.google.com", urlSession: self.urlSession)
        }
        
        afterEach {
            self.sut = nil
            self.urlSession = nil
            
            URLProtocolMock.requests = []
            
        }
        
        it("should fail if requestbuilder throws") {
            
            expect(self.runSUTExpectingFailure(endpoint: self.anyEndpoint(path: "\\b^ ")) {}).to(matchError(UnserAPIKitError.invalidURL(path: "", baseURL: "")))
        }
        
        it("should fail if response is not httpurlresponse") {
            expect(self.runSUTExpectingFailure() {
                URLProtocolMock.finishWith(response: self.anyURLResponse(), data: nil)
                }).notTo(beNil())
            
            expect(self.runSUTExpectingFailure() {
                URLProtocolMock.finishWith(response: self.anyURLResponse(), data: self.anyData())
                }).notTo(beNil())
        }
        
        it("should fail if session returned error") {
            
            expect(self.runSUTExpectingFailure() {
                    URLProtocolMock.failWith(error: self.anyError())
                }).to(matchError(self.anyError()))
        }
        
        it("should succeed if session returned no error and a httpurlresponse") {
            
            expect(self.runSUTExpectingSuccess() {
                URLProtocolMock.finishWith(response: self.anyHttpResponse(), data: self.anyData())
            }?.0) == self.anyData()
            
            expect(self.runSUTExpectingSuccess(){
                URLProtocolMock.finishWith(response: self.anyHttpResponse(), data: nil)
                }).notTo(beNil())
        }
    }
    
    private func runSUTExpectingSuccess(endpoint: Endpoint? = nil, action: () -> Void) -> (Data?, HTTPURLResponse)? {
        
        let result = self.runSUT(endpoint: endpoint ?? self.anyEndpoint(), action: action)
        switch result {
        case .success(let response):
            return response
        default:
            fail("should not fail")
            return nil
        }
    }
    
    private func runSUTExpectingFailure(endpoint: Endpoint? = nil, action: () -> Void) -> Error? {
        
        let result = self.runSUT(endpoint: endpoint ?? self.anyEndpoint(), action: action)
        switch result {
        case .failure(let error):
            return error
        default:
            fail("should not succeed")
            return nil
        }
    }
    
    private func runSUT(endpoint: Endpoint, action: () -> Void) -> HttpClient.Result {
        
        let ex = QuickSpec.current.expectation(description: "ex")

        var receivedResult: HttpClient.Result!
        self.sut.request(endpoint: endpoint, networkRequest: NetworkRequest(), completion: {
            receivedResult = $0
            ex.fulfill()
        })
        
        action()
        QuickSpec.current.wait(for: [ex], timeout: 1.0)
        return receivedResult

    }
    
    private func anyEndpoint(path: String = "tests") -> Endpoint {
        return Endpoint(path: path)
    }
    
    private func anyHttpResponse() -> HTTPURLResponse {
        return HTTPURLResponse(url: URL.init(string: "https://google.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
    
    private func anyURLResponse() -> URLResponse {
        return URLResponse(url: URL.init(string: "https://google.com")!, mimeType: nil, expectedContentLength: 500, textEncodingName: nil)
    }
    
    private func anyData() -> Data {
        return "testData".data(using: .utf8)!
    }
    
    private func anyError() -> Error {
        return NSError(domain: "whatever", code: 10, userInfo: nil)
    }
}
