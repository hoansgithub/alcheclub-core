//
//  StoreViewProduct.swift
//  ACCCoreStoreKit
//
//  Created by HoanNL on 3/7/24.
//

import Foundation
import StoreKit

public enum StoreViewProductPaymentMode: Int, Sendable, Codable {

    /// Price is charged one or more times
    case payAsYouGo = 0
    /// Price is charged once in advance
    case payUpFront = 1
    /// No initial charge
    case freeTrial = 2

}

public struct StoreViewProduct: Sendable, Codable, Identifiable {
    public let id: String
    public var labels: [String: String]
    public var purchased: Bool = false
    public let displayPrice: String
    public let displayName: String
    public let paymentMode: StoreViewProductPaymentMode?
    
    public init(id: String, labels: [String : String], purchased: Bool = false, displayPrice: String, displayName: String, paymentMode: StoreViewProductPaymentMode? = nil) {
        self.id = id
        self.labels = labels
        self.purchased = purchased
        self.displayPrice = displayPrice
        self.displayName = displayName
        self.paymentMode = paymentMode
    }
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
