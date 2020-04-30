import Foundation
import UnserAPIKit
import Quick
import Nimble

public func makeHttpURLResponse(statusCode: Int = 200) -> HTTPURLResponse {
  return HTTPURLResponse(
    url: URL(string: "https//www.google.com")!, statusCode: statusCode, httpVersion: nil,
    headerFields: nil)!
}

public func makeError() -> Error { return NSError(domain: "1", code: 1, userInfo: nil) }

public class HttpClientTestDouble: HttpClient {
  private var completion: ((HttpClient.Result) -> Void)? = nil
  var endpoint: Endpoint? = nil
  public var networkRequest: NetworkRequest? = nil
  public init() {}
  public func request(
    endpoint: Endpoint, networkRequest: NetworkRequest,
    completion: @escaping (HttpClient.Result) -> Void
  ) {
    self.endpoint = endpoint
    self.completion = completion
    self.networkRequest = networkRequest
  }
  public func completeRequest(_ result: HttpClient.Result) { self.completion?(result) }
  public func expectEndpoint(
    path: String, httpMethod: HttpMethod?, queryParameters: QueryParameters?, headers: Headers?,
    contentType: ContentType, acceptType: AcceptType, resolveAgainstBaseURL: Bool, data: Data?,
    body: [String: Encodable]? = nil
  ) {
    expect(self.endpoint?.path) == path
    if let httpMethod = httpMethod { expect(self.endpoint?.httpMethod) == httpMethod } else {
      expect(self.endpoint?.httpMethod).to(beNil())
    }
    if let queryParameters = queryParameters {
      expect(self.endpoint?.queryParameters) == queryParameters
    } else {
      expect(self.endpoint?.queryParameters).to(beNil())

    }
    if let headers = headers { expect(self.endpoint?.headers) == headers } else {
      expect(self.endpoint?.headers).to(beNil())

    }
    expect(self.endpoint?.contentType) == contentType
    expect(self.endpoint?.acceptType) == acceptType
    if let data = data { expect(self.endpoint?.data) == data } else {
      expect(self.endpoint?.data).to(beNil())
    }
  }
}
