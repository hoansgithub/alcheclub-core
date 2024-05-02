//
//  URLSession+nonisolated.swift
//  ACCCoreUtilities
//
//  Created by HoanNL on 17/04/2024.
//

import Foundation
extension URLSession {
    public nonisolated func getData(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await data(for: request)
    }
    
    public nonisolated func getData(for url: URL) async throws -> (Data, URLResponse) {
        try await data(from: url)
    }
}

