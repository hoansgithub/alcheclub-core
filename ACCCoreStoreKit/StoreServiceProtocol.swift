//
//  StoreServiceProtocol.swift
//  ACCCoreStoreKit
//
//  Created by HoanNL on 3/7/24.
//

import ACCCore
import Combine

public typealias ProductPurchaseResult = Result<String, StoreKitManagerError>
public protocol StoreServiceProtocol: ACCService {
    var productsPublisher: AnyPublisher<[StoreViewProduct], StoreKitManagerError> { get }
    func getViewModel(for identifier: String, defaultConfig: StoreViewModelConfig) -> StoreViewModelProtocol
    
    func purchase(product: StoreViewProduct, accountToken: UUID?) async throws -> ProductPurchaseResult
    
    func restore() async throws
}
