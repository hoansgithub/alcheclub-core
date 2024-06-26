//
//  ResponseValidator.swift
//  ACCCoreNetworking
//
//  Created by HoanNL on 25/6/24.
//

import Foundation
/// Validates that a response meets certain criteria. If it does not, throws an error.
public typealias ResponseValidator = @Sendable (HTTPURLResponse, Data?) throws -> Void

public let statusCodeIsIn200s: ResponseValidator = { response, data in
    guard 200 ..< 300 ~= response.statusCode else {
        throw NetworkError.non200StatusCode(statusCode: response.statusCode, data: data)
    }
}
