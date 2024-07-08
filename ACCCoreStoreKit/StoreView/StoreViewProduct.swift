//
//  StoreViewProduct.swift
//  ACCCoreStoreKit
//
//  Created by HoanNL on 3/7/24.
//

import Foundation
import StoreKit
public struct StoreViewProduct: Sendable, Codable, Identifiable {
    public let id: String
    public var labels: [String: String]
    public var purchased: Bool = false
    public let displayPrice: String
    public let displayName: String
}

extension StoreViewProduct {
    static func from(_ product: Product, labels: [String: String] = [:]) -> Self {
        return StoreViewProduct(id: product.id, 
                                  labels: labels,
                                  displayPrice: product.displayPrice,
                                  displayName: product.displayName)
    }
    
    public func label(for key: String, defaultValue: String = "") -> String {
        return labels[key] ?? defaultValue
    }
}
