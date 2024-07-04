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
    private let firstAppOpenClosedSubject = CurrentValueSubject<Bool, Never>(false)
    let firstAppOpenClosedPublisher: AnyPublisher<Bool, Never>
    
    private let stateSubject = CurrentValueSubject<ServiceState, Never>(.idle)
    let statePublisher: AnyPublisher<ServiceState, Never>
    private var adService: AdService?
    private var appOpenCancellable: AnyCancellable?
    private var adLoadCancellable: AnyCancellable?
    required init(adService: AdService?) {
        statePublisher = stateSubject
            .removeDuplicates()
            .eraseToAnyPublisher()
        firstAppOpenClosedPublisher = firstAppOpenClosedSubject
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
        adLoadCancellable?.cancel() 
        adLoadCancellable = adService?.statePublisher
            .filter({$0 == .ready})
            .prefix(1)
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] _ in
                Task {
                    try? await self?.adService?.loadAppOpenAd()
                    self?.showAppOpen()
                }
            })
        
        preloadFullScreenAds()
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        Task {
            try? await adService?.loadAppOpenAd()
        }
    }
}

extension AdPreloaderService {
    func preloadFullScreenAds() {
        appOpenCancellable?.cancel()
        appOpenCancellable = firstAppOpenClosedSubject.filter({$0})
            .prefix(1)
            .sink { [weak self] _ in
                self?.loadFullScreenAds()
            }
    }
    
    func loadFullScreenAds() {
        ACCLogger.print(self)
        Task.detached {[weak self] in
            try? await self?.adService?.loadInterstitialAd()
            try? await self?.adService?.loadRewardedInterstitialAd(options: nil)
            try? await self?.adService?.loadRewardedAd(options: nil)
        }
    }
    
    @MainActor private func showAppOpen() {
        do {
            try adService?.presentAppOpenAdIfAvailable(controller: nil, listener: { [weak self] state in
                switch state {
                case .didDismiss:
                    self?.firstAppOpenClosedSubject.send(true)
                case.failedToPresent(let err):
                    ACCLogger.print(err, level: .error)
                    self?.firstAppOpenClosedSubject.send(true)
                default:
                    break
                }
            })
        } catch {
            ACCLogger.print(error, level: .error)
        }
    }
}


