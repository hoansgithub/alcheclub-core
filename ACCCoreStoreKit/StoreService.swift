//
//  StoreService.swift
//  ACCCoreStoreKit
//
//  Created by HoanNL on 3/7/24.
//

import ACCCore
import Combine
import UIKit

open class StoreService: NSObject, @unchecked Sendable, 
                            StoreServiceProtocol,
                         ConfigurableObject {
    public enum StoreServiceConfigKey: String {
        case storeViewModelConfigs
        case storeViewProductLabels
    }
    
    //publishers
    public let productsPublisher: AnyPublisher<[StoreViewProduct], StoreKitManagerError>
    private let productsSubject = CurrentValueSubject<[StoreViewProduct], StoreKitManagerError>([])
    
    
    //RC keys
    private let storeViewModelConfigsKey: String
    private let storeViewProductLabelsKey: String
    
    //private props
    private let manager: StoreKitManager
    private let productIdentifiers: [String]
    private var storeViewModelConfigs: [StoreViewModelConfig]?
    private var storeViewProductLabelsSubject = CurrentValueSubject<[String : String], Never>([:])
    private var productsCancellable: AnyCancellable?
    
    required public init(productIdentifiers: [String],
                         storeViewModelConfigsKey: String = StoreServiceConfigKey.storeViewModelConfigs.rawValue,
                         storeViewProductLabelsKey: String = StoreServiceConfigKey.storeViewProductLabels.rawValue) {
        self.productIdentifiers = productIdentifiers
        self.manager = StoreKitManager()
        self.productsPublisher = productsSubject.filter({!$0.isEmpty})
            .eraseToAnyPublisher()
        self.storeViewModelConfigsKey = storeViewModelConfigsKey
        self.storeViewProductLabelsKey = storeViewProductLabelsKey
        super.init()
    }
    
    public func restore() async throws {
        try await manager.restore()
    }
    
    open func update(with config: ConfigContainer) {
        //TODO: - update product presenter here
        storeViewModelConfigs = config[storeViewModelConfigsKey]
        storeViewProductLabelsSubject.send(config[storeViewProductLabelsKey] ?? [:])
    }
    
    open func getViewModel(for identifier: String, defaultConfig: StoreViewModelConfig) -> StoreViewModelProtocol {
        let config = storeViewModelConfigs?.first(where: {$0.id == identifier}) ?? defaultConfig
        return StoreViewModel(config: config)
    }
    
    open func purchase(product: StoreViewProduct, accountToken: UUID? = nil) async throws -> ProductPurchaseResult {
        try await manager.purchase(productID: product.id, accountToken: accountToken)
    }
    
}

private extension StoreService {
    func restart() async throws {
        try await manager.start(productIdentifiers: productIdentifiers)
    }
    
    func registerObservers() {
        let productsPub = manager.allProductsPub
        let purchasedProductsPub = manager.purchasedProductsPub
        let productLabelsPub = storeViewProductLabelsSubject
        
        productsCancellable?.cancel()
        productsCancellable = Publishers.CombineLatest3(productsPub, purchasedProductsPub, productLabelsPub)
            .sink { [weak self] (products, purchasedProducts, productLabels) in
                guard let self else { return }
                let viewProducts = products.compactMap { product in
                    let purchased = purchasedProducts.contains(where: {$0.id == product.id})
                    var viewProduct = StoreViewProduct.from(product, labels: productLabels)
                    viewProduct.purchased = purchased
                    return viewProduct
                }
                self.productsSubject.send(viewProducts)
            }
    }
}

extension StoreService: UIApplicationDelegate {
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        Task {
            do {
                try await manager.start(productIdentifiers: productIdentifiers)
                registerObservers()
            } catch {
                ACCLogger.print(error, level: .error)
            }
        }
        return true
    }
    
    public func applicationDidBecomeActive(_ application: UIApplication) {
        Task{
            do {
                try await restart()
            } catch {
                ACCLogger.print(error, level: .error)
            }
        }
    }
}

extension StoreService: UIWindowSceneDelegate {
    public func sceneDidBecomeActive(_ scene: UIScene) {
        Task{
            do {
                try await restart()
            } catch {
                ACCLogger.print(error, level: .error)
            }
        }
    }
}
