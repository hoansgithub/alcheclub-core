//
//  NetworkError.swift
//  ACCCoreNetworking
//
//  Created by HoanNL on 25/6/24.
//

import Foundation

public enum NetworkError: Error, Equatable {
    case non200StatusCode(statusCode: Int, data: Data?)
    case invalidResponseFormat
    case decoding(error: Error)
    case decodingString
    case noDataInResponse
}

public extension Equatable where Self: Error {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs as Error == rhs as Error
    }
}

public func == (lhs: Error, rhs: Error) -> Bool {
    guard type(of: lhs) == type(of: rhs) else { return false }
    let error1 = lhs as NSError
    let error2 = rhs as NSError
    return error1.domain == error2.domain && error1.code == error2.code && "\(lhs)" == "\(rhs)"
}
