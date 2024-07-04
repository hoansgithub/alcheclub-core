//
//  ATTService.swift
//  ACCCore
//
//  Created by HoanNL on 02/05/2024.
//

import Foundation
import Combine
import AppTrackingTransparency
import UIKit
public final class ATTService: NSObject, @unchecked Sendable, ATTServiceProtocol, TrackableService {
    public weak var eventDelegate: TrackableServiceDelegate?
    
    
    public static let shared = ATTService()
    //publishers
    private let stateSubject = CurrentValueSubject<ServiceState, Never>(.idle)
    public let statePublisher: AnyPublisher<ServiceState, Never>
    
    private var activeStateSubject = CurrentValueSubject<Bool, Never>(false)
    private var activeStateCancellable: AnyCancellable?
    private override init() {
        self.statePublisher = stateSubject.removeDuplicates().eraseToAnyPublisher()
        super.init()
    }
    
    public var authStatus: ATTrackingManager.AuthorizationStatus {
        ATTrackingManager.trackingAuthorizationStatus
    }
}

extension ATTService: UIApplicationDelegate {
    public func applicationDidBecomeActive(_ application: UIApplication) {
        activeStateSubject.send(true)
    }
}

extension ATTService: UIWindowSceneDelegate {
    public func sceneDidBecomeActive(_ scene: UIScene) {
        activeStateSubject.send(true)
    }
}

public extension ATTService {
    @MainActor func requestTrackingAuthorization() async -> ATTrackingManager.AuthorizationStatus {
        activeStateCancellable?.cancel()
        return await withCheckedContinuation { cont in
            activeStateCancellable = activeStateSubject
                .filter({$0})
                .prefix(1)
                .sink { [weak self] val in
                    Task {
                        let stt = await ATTrackingManager.requestTrackingAuthorization()
                        self?.stateSubject.send(.ready)
                        self?.trackATTAuthorization(status: stt)
                        cont.resume(returning: stt)
                    }
                }
        }
    }
}

private extension ATTService {
    func trackATTAuthorization(status: ATTrackingManager.AuthorizationStatus) {
        let userDefaults = UserDefaults.standard
        let flag = "ATTService.trackATTAuthorization"
        if !userDefaults.bool(forKey: flag) {
            let paramValue: String = status == .authorized ? "yes" : "no"
            let param = ["value": paramValue]
            let event = AnalyticsEvent("acc_att_action", params: param)
            track(event: event)
            userDefaults.set(true, forKey: flag)
            userDefaults.synchronize()
        }
        
    }
}


