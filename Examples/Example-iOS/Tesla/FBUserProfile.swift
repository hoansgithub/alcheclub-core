//
//  FBUserProfile.swift
//  Example-iOS
//
//  Created by HoanNL on 2/7/24.
//

import Foundation
struct FBUserProfile: Codable {
    struct User: Codable {
        let avatar: String
    }
    
    let user: User
}
