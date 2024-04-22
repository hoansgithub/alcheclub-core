//
//  ServiceProviderAppDelegate.swift
//  ACCCore
//
//  Created by HoanNL on 19/03/2024.
//

import UIKit
import Combine
open class ServiceProviderAppDelegate: UIResponder, UIApplicationDelegate, UIWindowSceneDelegate, ServiceProviderProtocol, AnalyticsEventTrackerProtocol {
    nonisolated open var analyticsPlatforms: [any AnalyticsPlatformProtocol] {
        return []
    }
    
    nonisolated open var services: [ServiceProtocol] {
        return []
    }
    
    nonisolated open func getService<S>(_ type: S.Type) -> S? {
        services.first(where: {$0 is S }) as? S
    }
    
    
    //config center
    nonisolated open var configCenter: ConfigCenterProtocol? {
        return nil
    }
    
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: UIApplicationDelegate conformation
    open var window: UIWindow?
    
    
    public override init() {
        super.init()
        registerConfigCenter(configCenter)
    }
    
    open func registerConfigCenter(_ center: ConfigCenterProtocol?) {
        guard let configCenter = configCenter else {
            ACCLogger.print("To have the remote config observers behave as expected, you must override the property `nonisolated open var configCenter: ConfigCenterProtocol?` from ServiceProviderAppDelegate", level: .fault)
            return
        }
        configCenter.configPublisher.sink(receiveValue: { [weak self] cfObj in
            guard let self, let rcObj = cfObj else { return }
            self.services.compactMap({$0 as? ConfigurableProtocol}).forEach { configurable in
                configurable.update(with: rcObj)
            }
        }).store(in: &cancellables)
    }
}

public extension ServiceProviderAppDelegate {
    @discardableResult
    func apply<T, S>(_ work: (ServiceProtocol, @escaping (T) -> Void) -> S?, completionHandler: @escaping ([T]) -> Void) -> [S] {
        let dispatchGroup = DispatchGroup()
        var results: [T] = []
        var returns: [S] = []

        for service in services {
            dispatchGroup.enter()

            let returned = work(service) { result in
                results.append(result)
                dispatchGroup.leave()
            }

            if let returned = returned {
                returns.append(returned)
            } else {
                dispatchGroup.leave()
            }

            if returned == nil {}
        }

        dispatchGroup.notify(queue: .main) {
            completionHandler(results)
        }
        return returns
    }
}
