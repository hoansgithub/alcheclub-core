//
//  StoreServiceProtocol.swift
//  ACCCoreStoreKit
//
//  Created by HoanNL on 3/7/24.
//

import ACCCore
import Combine
public protocol StoreServiceProtocol: ACCService {
    var productsPublisher: AnyPublisher<[StoreViewProduct], Never> { get }
    func getViewModel(for identifier: String, defaultConfig: StoreViewModelConfig) -> StoreViewModel
    
    func purchase(product: StoreViewProduct, accountToken: UUID?) async throws -> StoreKitManager.ProductPurchaseResult
    
    func restore() async throws
}
