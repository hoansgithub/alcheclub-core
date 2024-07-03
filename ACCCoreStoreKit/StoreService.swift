//
//  StoreService.swift
//  ACCCoreStoreKit
//
//  Created by HoanNL on 3/7/24.
//

import ACCCore
import Combine
import UIKit

open class StoreService: NSObject, @unchecked Sendable, StoreServiceProtocol {
    //publishers
    private let stateSubject = CurrentValueSubject<ServiceState, Never>(.idle)
    public let statePublisher: AnyPublisher<ServiceState, Never>
    
    private let manager: StoreProductManager
    private let productIdentifiers: [String]
    required public init(productIdentifiers: [String]) {
        self.productIdentifiers = productIdentifiers
        self.manager = StoreProductManager()
        self.statePublisher = stateSubject
            .removeDuplicates()
            .eraseToAnyPublisher()
        super.init()
    }
    
    func restore() async throws {
        try await manager.restore()
    }
}

private extension StoreService {
    func restart() async throws {
        try await manager.start(productIdentifiers: productIdentifiers)
    }
}

extension StoreService: UIApplicationDelegate {
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        Task {
            do {
                try await manager.start(productIdentifiers: productIdentifiers)
                stateSubject.send(.ready)
            } catch {
                ACCLogger.print(error, level: .error)
            }
        }
        return true
    }
    
    public func applicationDidBecomeActive(_ application: UIApplication) {
        Task.detached { @MainActor [weak self] in
            do {
                try await self?.restore()
            } catch {
                ACCLogger.print(error, level: .error)
            }
        }
    }
}

extension StoreService: ConfigurableProtocol {
    public func update(with config: ConfigObject) {
        //TODO: - update product presenter here
    }
}
