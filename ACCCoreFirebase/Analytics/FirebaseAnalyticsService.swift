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
public final class FirebaseAnalyticsService: NSObject, FirebaseAnalyticsServiceProtocol {
    public var id: String = "FirebaseAnalytics"
    
    private let stateSubject = CurrentValueSubject<ServiceState, Never>(.idle)
    public let statePublisher: AnyPublisher<ServiceState, Never>
    
    
    private var coreService: FirebaseCoreServiceProtocol
    private var cancellables: Set<AnyCancellable> = []
    private var _canTrack = false
    required public init(coreService: FirebaseCoreServiceProtocol) {
        self.statePublisher = stateSubject.removeDuplicates().eraseToAnyPublisher()
        self.coreService = coreService
        super.init()
    }
    
    
    
    
}

extension FirebaseAnalyticsService: UIApplicationDelegate {
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        coreService.statePublisher
            .filter({$0 == .ready})
            .prefix(1).sink { [weak self] state in
            self?.stateSubject.send(state)
            self?._canTrack = state == .ready
        }.store(in: &cancellables)
        return true
    }
}

///AnalyticsPlatformProtocol
public extension FirebaseAnalyticsService {
    
    var canTrack: Bool { _canTrack }
    
    func track(event: AnalyticsEvent) {
        Analytics.logEvent(event.name, parameters: event.params)
    }
}
