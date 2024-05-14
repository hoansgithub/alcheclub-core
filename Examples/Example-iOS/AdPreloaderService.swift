//
//  AdPreloaderService.swift
//  Example-iOS
//
//  Created by HoanNL on 14/05/2024.
//

import Foundation
import ACCCore
import ACCCoreAdMob
import Combine
import UIKit
class AdPreloaderService: NSObject, @unchecked Sendable, AdPreloaderServiceProtocol {
    private let appOpenClosedSubject = CurrentValueSubject<Bool, Never>(false)
    let appOpenClosedPublisher: AnyPublisher<Bool, Never>
    
    private let stateSubject = CurrentValueSubject<ServiceState, Never>(.idle)
    let statePublisher: AnyPublisher<ServiceState, Never>
    private var adService: AdServiceProtocol?
    private var appOpenCancellable: AnyCancellable?
    required init(adService: AdServiceProtocol?) {
        statePublisher = stateSubject
            .removeDuplicates()
            .eraseToAnyPublisher()
        appOpenClosedPublisher = appOpenClosedSubject
            .removeDuplicates()
            .eraseToAnyPublisher()
        self.adService = adService
        super.init()
    }
}

extension AdPreloaderService: UIApplicationDelegate {
    
}

extension AdPreloaderService: UIWindowSceneDelegate {
    func sceneDidBecomeActive(_ scene: UIScene) {
        waitAppOpen()
    }
}

extension AdPreloaderService {
    func waitAppOpen() {
        appOpenCancellable?.cancel()
        appOpenCancellable = adService?.statePublisher
            .filter({$0 == .ready})
            .prefix(1)
            .sink(receiveValue: { [weak self] _ in
                self?.getAppOpen()
            })
    }
    
    private func getAppOpen() {
        Task {
            do {
                try await adService?.loadAppOpenAd()
                await showAppOpen()
            } catch {
                ACCLogger.print(error, level: .error)
                appOpenClosedSubject.send(true)
            }
        }
    }
    
    @MainActor private func showAppOpen() {
        do {
            try adService?.showAppOpenAdIfAvailable(controller: nil, listener: { [weak self] state in
                switch state {
                case .didDismiss:
                    self?.appOpenClosedSubject.send(true)
                case.failedToPresent(let err):
                    ACCLogger.print(err, level: .error)
                    self?.appOpenClosedSubject.send(true)
                default:
                    break
                }
            })
        } catch {
            ACCLogger.print(error, level: .error)
        }
    }
}


