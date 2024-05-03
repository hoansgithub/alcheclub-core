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
public final class ATTService: NSObject, ATTServiceProtocol {
    
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
                        cont.resume(returning: stt)
                    }
                }
        }
    }
}


