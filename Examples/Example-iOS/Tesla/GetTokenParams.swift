//
//  GetTokenParams.swift
//  Example-iOS
//
//  Created by HoanNL on 1/7/24.
//

import Foundation
struct GetTokenParams: Codable {
    let code: String
    let grant_type: String
    let redirect_uri: String
    
    init(code: String, grant_type: String = "authorization_code", redirect_url: String = "fitracker://auth") {
        self.code = code
        self.grant_type = grant_type
        self.redirect_uri = redirect_url
    }
    
    var bodyParams: [String :Any ] {
        return [
            "code": code,
            "grant_type": grant_type,
            "redirect_uri": redirect_uri
        ]
    }
}
