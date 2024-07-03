//
//  PresentableProduct.swift
//  ACCCoreStoreKit
//
//  Created by HoanNL on 3/7/24.
//

import Foundation
struct PresentableProduct: Codable, Identifiable {
    let id: String
    let localizedLabelKeys: [String: String]
}
