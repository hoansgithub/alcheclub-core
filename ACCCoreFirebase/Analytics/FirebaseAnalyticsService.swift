//
//  FirebaseAnalyticsService.swift
//  ACCCoreFirebase
//
//  Created by HoanNL on 19/04/2024.
//

import Foundation
import ACCCore
import Combine
import UIKit
import FirebaseAnalytics
public final class FirebaseAnalyticsService: NSObject, @unchecked Sendable, FirebaseAnalyticsServiceProtocol {
    private let stateSubject = CurrentValueSubject<ServiceState, Never>(.idle)
    public let statePublisher: AnyPublisher<ServiceState, Never>
    
    
    private var firebaseCoreService: FirebaseCoreServiceProtocol
    private var cancellables: Set<AnyCancellable> = []
    private var _canTrack = false
    nonisolated required public init(coreService: FirebaseCoreServiceProtocol) {
        self.statePublisher = stateSubject.eraseToAnyPublisher()
        self.firebaseCoreService = coreService
        super.init()
    }
    
   
    
    
}

extension FirebaseAnalyticsService: UIApplicationDelegate {
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        firebaseCoreService.statePublisher.sink { [weak self] state in
            self?.stateSubject.send(state)
            self?._canTrack = state == .ready
        }.store(in: &cancellables)
        return true
    }
}

///AnalyticsPlatformProtocol
public extension FirebaseAnalyticsService {
    
    nonisolated var canTrack: Bool { _canTrack }
    
    nonisolated func track(event: AnalyticsEvent) {
        Analytics.logEvent(event.name, parameters: event.params)
    }
}
