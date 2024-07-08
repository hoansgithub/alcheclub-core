//
//  StoreViewModelConfig.swift
//  ACCCoreStoreKit
//
//  Created by HoanNL on 4/7/24.
//

import Foundation
public struct StoreViewModelConfig: Codable, Identifiable {
    public let id: String
    public let itemIdentifiers: [String]
    public init(id: String, itemIdentifiers: [String]) {
        self.id = id
        self.itemIdentifiers = itemIdentifiers
    }
}
