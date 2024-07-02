//
//  TokenResponse.swift
//  Example-iOS
//
//  Created by HoanNL on 1/7/24.
//

import Foundation
struct TokenResponse: Codable {
    let access_token: String
    let refresh_token: String
    let user_id: String
}
