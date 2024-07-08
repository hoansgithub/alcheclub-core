//
//  StoreViewModel.swift
//  ACCCoreStoreKit
//
//  Created by HoanNL on 3/7/24.
//

import Foundation
import Combine
import ACCCore
open class StoreViewModel: ObservableObject {
    @Published public private(set) var products: [StoreViewProduct] = []
    public let config: StoreViewModelConfig
    private let storeService: StoreServiceProtocol?
    private var productsCancellable: AnyCancellable?
    public init(config: StoreViewModelConfig) {
        self.config = config
        self.storeService = ACCApp.getService(StoreServiceProtocol.self)
        registerObservers()
    }
    
    deinit {
        ACCLogger.print(self)
    }
    
    
}

public extension StoreViewModel {
    func purchase(product: StoreViewProduct, accountToken: UUID? = nil) async {
        do {
            let res = try await storeService?.purchase(product: product, accountToken: accountToken)
            
        } catch {
            //TODO: - show store error
            ACCLogger.print(error, level: .fault)
        }
    }
}

private extension StoreViewModel {
    func registerObservers() {
        productsCancellable?.cancel()
        productsCancellable = storeService?.productsPublisher.sink(receiveValue: { [weak self] prods in
            guard let self else { return }
            
            self.products = self.config.itemIdentifiers.compactMap({ identifier in
                return prods.first(where: {$0.id == identifier})
            })
        })
    }
}
