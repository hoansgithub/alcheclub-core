//
//  SplashViewModel.swift
//  Example-iOS
//
//  Created by HoanNL on 23/04/2024.
//

import Foundation
import ACCCore
import ACCCoreFirebase
import ACCCoreAdMob
import Combine
import UIKit
protocol SplashViewModelProtocol: Sendable, BaseViewModelProtocol {
    func onViewAppear() async
    func presentConsentFormIfRequired(vc: UIViewController) async
}

class SplashViewModel: @unchecked Sendable, SplashViewModelProtocol {
    var firRCService: FirebaseRemoteConfigServiceProtocol?
    var umpService: GoogleUMPServiceProtocol?
    var adPreloaderService: AdPreloaderServiceProtocol?
    
    private var stateCancellable: AnyCancellable?
    private var adCancellable: AnyCancellable?
    init() {
        self.firRCService = ACCApp.getService(FirebaseRemoteConfigServiceProtocol.self)
        self.umpService = ACCApp.getService(GoogleUMPServiceProtocol.self)
        self.adPreloaderService = ACCApp.getService(AdPreloaderServiceProtocol.self)
    }
    
    func presentConsentFormIfRequired(vc: UIViewController) async {
        do {
            try await umpService?.presentConsentFormIfRequired(from: vc)
        } catch {
            ACCLogger.print(error.localizedDescription, level: .error)
        }
        
    }
    
    func onViewAppear() async {
        registerEventObserver()
        _ = await ATTService.shared.requestTrackingAuthorization()
    }
    
    deinit {
        ACCLogger.print(self)
    }
}

private extension SplashViewModel {
    func registerEventObserver() {
        stateCancellable?.cancel()
        let attStatePublisher = ATTService.shared.statePublisher
            .filter({$0 == .ready})
            .prefix(1)
        if let rcStatePublisher = firRCService?.statePublisher
            .filter({$0 == .ready})
            .prefix(1),
           let appOpenClosed = adPreloaderService?.firstAppOpenClosedPublisher.filter({$0}).prefix(1) {
            stateCancellable = Publishers.CombineLatest3(attStatePublisher, rcStatePublisher, appOpenClosed)
                .receive(on: RunLoop.main)
                .sink { (stt) in
                    Task {
                        await AppSession.shared.configurateState()
                    }
                }
        } else {
            Task {
                await AppSession.shared.configurateState()
            }
        }
        
    }
}
