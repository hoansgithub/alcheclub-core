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

public struct StoreViewProduct: Sendable, Identifiable, Equatable {
    public let id: String
    public var price: Decimal
    public var labels: [String: String]
    public var purchased: Bool = false
    public let displayPrice: String
    public let displayName: String
    public let paymentMode: StoreViewProductPaymentMode?
    public let priceLocale: Locale?
    
    public init(id: String, price: Decimal, labels: [String : String], purchased: Bool = false, displayPrice: String, displayName: String, paymentMode: StoreViewProductPaymentMode? = nil, priceLocale: Locale?) {
        self.id = id
        self.price = price
        self.labels = labels
        self.purchased = purchased
        self.displayPrice = displayPrice
        self.displayName = displayName
        self.paymentMode = paymentMode
        self.priceLocale = priceLocale
    }
}

extension StoreViewProduct {
    static func from(_ product: Product, labels: [String: String] = [:]) -> Self {
        return StoreViewProduct(id: product.id,
                                price: product.price,
                                labels: labels,
                                displayPrice: product.displayPrice,
                                displayName: product.displayName, priceLocale: product.priceFormatStyle.locale)
    }
    
    public func label(for key: String, defaultValue: String = "") -> String {
        return labels[key] ?? defaultValue
    }
}
