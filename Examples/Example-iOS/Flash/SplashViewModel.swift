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
protocol SplashViewModelProtocol: BaseViewModelProtocol {
    func onViewAppear() async
    func presentConsentFormIfRequired(vc: UIViewController) async
}

class SplashViewModel: @unchecked Sendable, SplashViewModelProtocol {
    var serviceProvider: ServiceProviderAppDelegate
    var firRCService: FirebaseRemoteConfigServiceProtocol?
    var umpService: GoogleUMPServiceProtocol?
    @MainActor var fullScreenController = UIViewController()
    
    private var stateCancellable: AnyCancellable?
    init(serviceProvider: ServiceProviderAppDelegate) {
        self.serviceProvider = serviceProvider
        self.firRCService = serviceProvider.getService(FirebaseRemoteConfigServiceProtocol.self)
        self.umpService = serviceProvider.getService(GoogleUMPServiceProtocol.self)
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
            .prefix(1) {
            stateCancellable = Publishers.CombineLatest(attStatePublisher, rcStatePublisher)
                .receive(on: RunLoop.main)
                .sink { (stt) in
                    AppSession.shared.configurateState()
                }
        } else {
            AppSession.shared.configurateState()
        }
        
    }
}
