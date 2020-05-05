//
//  File.swift
//  
//
//  Created by Abdulhaq Emhemmed on 5/2/20.
//

import Foundation

public func buildFormData(with params: [String: Any]) -> Data {
      var components = URLComponents()
      components.queryItems = params.map { (k, v) in
        return URLQueryItem(name: k, value: "\(v)")
      }
      components.percentEncodedQuery = components.percentEncodedQuery?
          .replacingOccurrences(of: "+", with: "%2B")
  
  return components.percentEncodedQuery!.data(using: .utf8)!
}
