//
//  RequestError.swift
//  Example-iOS
//
//  Created by HoanNL on 1/7/24.
//

import Foundation
struct RequestError: Codable {
    let errorType: String
    let message: String
}

struct RequestErrors: Codable {
    let errors: [RequestError]
}
