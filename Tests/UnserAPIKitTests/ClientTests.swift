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
    
    var sut: Client!
    var urlSession: URLSession!
    
    
    override func spec() {
        
        beforeEach {
        URLProtocol.registerClass(URLProtocolMock.self)
            let config = URLSessionConfiguration.ephemeral
            config.protocolClasses = [URLProtocolMock.self]
            self.urlSession = URLSession(configuration: config)
            self.sut = Client(baseURL: "https://www.google.com", urlSession: self.urlSession)
        }
        
        afterEach {
            self.sut = nil
            self.urlSession = nil
                    
            URLProtocolMock.requests = []

        }
        
        it("should throw error if requestbuilder throws") {
            expect {try self.sut.request(endpoint: Endpoint(path: "\\b "), networkRequest: NetworkRequest(), completionHandler: { _,_,_ in })}.to(throwError())
        }
        
        it("should run datatask given an endpoint and a network request") {
            
           let httpResponse = HTTPURLResponse(url: URL.init(string: "https://google.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            
            let data = "test".data(using: .utf8)!
            URLProtocolMock.finishWith(response: httpResponse, data: data)
            let ex = QuickSpec.current.expectation(description: "ex")
            try! self.sut.request(endpoint: Endpoint(path: "test"), networkRequest: NetworkRequest()) { data, response, error in
                ex.fulfill()
                expect(data) == data
                expect((response as? HTTPURLResponse)?.statusCode) == httpResponse.statusCode
                expect((response as? HTTPURLResponse)?.url) == httpResponse.url
                expect(error).to(beNil())
            }
            
            QuickSpec.current.waitForExpectations(timeout: 3, handler: nil)
        }
        
        it("should run datatask given an endpoint and a network request (failure)") {
            
            let error = NSError(domain: "whatever", code: 10, userInfo: nil)
            
            URLProtocolMock.failWith(error: error)
            let ex = QuickSpec.current.expectation(description: "ex")
            try! self.sut.request(endpoint: Endpoint(path: "test"), networkRequest: NetworkRequest()) { data, response, error in
                ex.fulfill()
                expect(data).to(beNil())
                expect(response).to(beNil())
                expect(error).to(matchError(error!))
            }
            
            QuickSpec.current.waitForExpectations(timeout: 3, handler: nil)
        }
        
    }
}
