//
//  BearerTokenRequestModifier.swift
//  ACCCoreNetworking
//
//  Created by HoanNL on 25/6/24.
//

import Foundation
/// A class to modify a `URLRequest` and insert a header with `Bearer xxx` with a `Authorization` key
public class BearerTokenRequestModifier: HeaderRequestModifier {

    public init(authenticationToken: String) {
        let bearerTokenHeader = "Bearer \(authenticationToken)"
        super.init(key: "Authorization", value: bearerTokenHeader)
    }
}

