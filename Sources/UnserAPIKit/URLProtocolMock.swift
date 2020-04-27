import Foundation

class URLProtocolMock: URLProtocol {
    static var testURLs = [URL?: Data]()
    

    static var startLoadingResponse: ((_ protocol: URLProtocolMock) -> Void)? = nil
    
    static func finishWith(response: URLResponse, data: Data?) {
        URLProtocolMock.startLoadingResponse = { mockProtocol in
            mockProtocol.client?.urlProtocol(mockProtocol, didReceive: response, cacheStoragePolicy: .notAllowed)
            if let data = data {
                mockProtocol.client?.urlProtocol(mockProtocol, didLoad: data)
            }
            mockProtocol.client?.urlProtocolDidFinishLoading(mockProtocol)
        }
    }
    
    static func failWith(error: Error) {
        URLProtocolMock.startLoadingResponse = { mockProtocol in
            mockProtocol.client?.urlProtocol(mockProtocol, didFailWithError: error)
        }
    }

  static var requests: [URLRequest] = []

  public override init(request: URLRequest, cachedResponse: CachedURLResponse?, client: URLProtocolClient?) {
    super.init(request: request, cachedResponse: cachedResponse, client: client)

    
  }
      
  public override class func canInit(with task: URLSessionTask) -> Bool {
    
    return true
  }
  override public class func canInit(with request: URLRequest) -> Bool {

        return true
    }

  override public class func canonicalRequest(for request: URLRequest) -> URLRequest {
    
    URLProtocolMock.requests.append(request)
        return request
    }
  
  

  override public func startLoading() {
    
    URLProtocolMock.startLoadingResponse?(self)
  }

  override public func stopLoading() {
    
  }
}
