//
//  StoreViewModel.swift
//  ACCCoreStoreKit
//
//  Created by HoanNL on 3/7/24.
//

import Foundation
import Combine
import ACCCore

public enum StoreViewModelState: Equatable {
    case loading, idle, purchasing, error(err: StoreKitManagerError)
}

public protocol StoreViewModelProtocol: Sendable, AnyObject {
    var products: [StoreViewProduct] { get set }
    var state: StoreViewModelState { get set }
    var config: StoreViewModelConfig { get set }
    init(config: StoreViewModelConfig)
    
    func purchase(product: StoreViewProduct, accountToken: UUID?) async -> ProductPurchaseResult
    func restore() async
}

open class StoreViewModel: StoreViewModelProtocol, @unchecked Sendable, ObservableObject {
    @Published public var products: [StoreViewProduct] = []
    @Published public var state: StoreViewModelState = .idle
    public var config: StoreViewModelConfig
    private let storeService: StoreServiceProtocol?
    private var productsCancellable: AnyCancellable?
    required public init(config: StoreViewModelConfig) {
        self.config = config
        self.storeService = ACCApp.getService(StoreServiceProtocol.self)
        registerObservers()
    }
    
    deinit {
        ACCLogger.print(self)
    }
    
    
}

public extension StoreViewModel {
    func purchase(product: StoreViewProduct, accountToken: UUID? = nil) async -> ProductPurchaseResult {
        state = .purchasing
        do {
            let res = try await storeService?.purchase(product: product, accountToken: accountToken)
            switch res {
            case .success(_):
                //TODO: track transaction if needed
                state = .idle
                break
            case .none:
                state = .idle
                break
            case .some(.failure(let error)):
                state = .error(err: error)
            }
            
            return res ?? .failure(.unknown)
            
        } catch {
            //TODO: - show store error
            state = .error(err: .unknown)
            return .failure(.unknown)
        }
        
    }
    
    func restore() async {
        do {
            try await storeService?.restore()
        } catch {
            state = .error(err: .canNotRestore)
        }
    }
}

private extension StoreViewModel {
    func registerObservers() {
        state = .loading
        productsCancellable?.cancel()
        productsCancellable = storeService?
            .productsPublisher
            .filter({!$0.isEmpty})
            .timeout(.seconds(5), scheduler: RunLoop.main, customError: {.unknown})
            .sink(receiveCompletion: { [weak self] completion in
                guard let self else { return }
                switch completion {
                case .finished:
                    self.state = .idle
                case .failure(let failure):
                    self.state = .error(err: failure)
                }
            }, receiveValue: { [weak self] prods in
                guard let self else { return }
                
                self.products = self.config.itemIdentifiers.compactMap({ identifier in
                    return prods.first(where: {$0.id == identifier})
                })
            })
    }
}
