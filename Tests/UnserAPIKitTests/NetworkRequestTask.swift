//
//  File.swift
//  
//
//  Created by Abdulhaq Emhemmed on 3/18/20.
//

import Foundation
import XCTest
import Quick
import Nimble

@testable import UnserAPIKit

final class URLSessionMockTask: URLSessionTaskProtocol {
    static var resumeCallsCount = 0
    static var cancelCallsCount = 0
    static var preconditionFailed: Bool = false
    
    func resume() {
        URLSessionMockTask.resumeCallsCount += 1
    }
    
    func cancel() {
        URLSessionMockTask.cancelCallsCount += 1
    }
}

final class NetworkRequestTests: QuickSpec {
        
    var sut: NetworkRequest!
    var mockTask: URLSessionMockTask!
    
    override func spec() {
        
        beforeEach {
           
            self.sut = NetworkRequest()
            self.mockTask = URLSessionMockTask()
            URLSessionMockTask.resumeCallsCount = 0
            
        
        }
        
        afterEach {
            self.sut = nil
            self.mockTask = nil

        }
        
        it("should resume task with start if task is not set yet") {            expect(URLSessionMockTask.resumeCallsCount) == 0

            self.sut.start(self.mockTask)
            expect(URLSessionMockTask.resumeCallsCount) == 1
            
        }
        
        it("should cancel task with cancel") {
            self.sut.start(self.mockTask)
            expect(URLSessionMockTask.cancelCallsCount) == 0

            self.sut.cancel()
            expect(URLSessionMockTask.cancelCallsCount) == 1
            
        }
        
        // NOTE: - Currently not supported in spm (Nimble problems)
//        it("should not resume twice in case start is  called twice") {
//            self.sut.start(self.mockTask)
//            expect {self.sut.start(self.mockTask)}.to(throwAssertion())
//        }
    }
}
