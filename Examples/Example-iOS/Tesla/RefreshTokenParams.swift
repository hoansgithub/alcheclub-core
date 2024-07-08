//
//  RefreshTokenParams.swift
//  Example-iOS
//
//  Created by HoanNL on 8/7/24.
//

import Foundation
struct RefreshTokenParams: Codable {
    let grant_type: String
    let refresh_token: String
    let client_id: String
    
    var bodyParams: [String :Any ] {
        return [
            "refresh_token": refresh_token,
            "grant_type": grant_type,
            "client_id": client_id
        ]
    }
}
