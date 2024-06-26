//
//  URL+Networking.swift
//  ACCCoreNetworking
//
//  Created by HoanNL on 25/6/24.
//

import Foundation

extension URL: ConvertsToURLRequest {
    public func asURLRequest() -> URLRequest {
        return URLRequest(url: self)
    }
}
