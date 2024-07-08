//
//  StorePreset.swift
//  Example-iOS
//
//  Created by HoanNL on 8/7/24.
//

import ACCCoreStoreKit
struct StorePreset {
    static let shared = StorePreset()
    private init() {}
    
    var defaultConfig: StoreViewModelConfig {
        return StoreViewModelConfig(id: "StoreOneView", itemIdentifiers: ["Lifetime", "freetrialweekly"])
    }
    
    var productIdentifiers: [String] = ["Lifetime", "freetrialweekly", "fiftytokens", "oneweekpremium"]
}
