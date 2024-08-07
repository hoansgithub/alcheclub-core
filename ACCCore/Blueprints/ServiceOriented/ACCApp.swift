//
//  ACCApp.swift
//  ACCCore
//
//  Created by HoanNL on 07/05/2024.
//

import Foundation
import Combine
public final class ACCApp: @unchecked Sendable, ServiceProvider, AnalyticsEventTracker {
    
    
    private var services: [ACCService] = []
    public var analyticsPlatforms: [any AnalyticsPlatform] = []
    private var configCenter: ConfigCenter? = nil
    
    private init() {}
    public static let app = ACCApp()
    private var didConfigure = false
    private var cancellables: Set<AnyCancellable> = []
    /**
     Global Services container for preventing SwiftUI UIApplicationDelegateAdaptor's issue:
        UIApplicationDelegate instance may initiated multiple times:
     https://stackoverflow.com/questions/66156857/swiftui-2-accessing-appdelegate
     */
    public static func configure(services: [ACCService],
                                 analyticsPlatforms: [any AnalyticsPlatform],
                                 configCenter: ConfigCenter?) {
        if !app.didConfigure {
            app.didConfigure = true
            app.services = services
            app.analyticsPlatforms = analyticsPlatforms
            app.registerConfigCenter(configCenter)
            app.registerServiceEventListener()
            ACCLogger.print("ACCApp is ready!", level: .info)
        } else {
            ACCLogger.print("ACCApp is already set up!", level: .fault)
        }
    }
}

private extension ACCApp {
    func registerConfigCenter(_ center: ConfigCenter?) {
        self.configCenter = center
        guard let configCenter = configCenter else {
            ACCLogger.print("To have the remote config observers behave as expected, you must set a ConfigCenter for ACCApp", level: .fault)
            return
        }
        configCenter.publisher.sink(receiveValue: { [weak self] rcObj in
            guard let self else { return }
            self.services.compactMap({$0 as? ConfigurableObject}).forEach { configurable in
                configurable.update(with: rcObj)
            }
        }).store(in: &cancellables)
    }
    
    func registerServiceEventListener() {
        self.services.compactMap({$0 as? TrackableService}).forEach { [weak self] service in
            service.eventDelegate = self
        }
    }
}


public extension ACCApp {
    static func getService<S>(_ type: S.Type) -> S? {
        app.services.first(where: {$0 is S }) as? S
    }
    
    static func mapServices<E>(_ transform: (ACCService) -> E?) -> [E] {
        app.services.compactMap(transform)
    }
    
    @discardableResult
    static func apply<T, S>(_ work: (ACCService, @escaping (T) -> Void) -> S?, completionHandler: @escaping ([T]) -> Void) -> [S] {
        let dispatchGroup = DispatchGroup()
        var results: [T] = []
        var returns: [S] = []
        
        for service in app.services {
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
    
    static func track(event: AnalyticsEvent) {
        app.track(event: event)
    }
}

extension ACCApp: TrackableServiceDelegate {
    public func trackableService(_ service: TrackableService, didSend event: AnalyticsEvent) {
        track(event: event)
    }
}
