//
//  SplashViewModel.swift
//  Example-iOS
//
//  Created by HoanNL on 23/04/2024.
//

import Foundation
import ACCCore
import ACCCoreFirebase
import Combine
protocol SplashViewModelProtocol: BaseViewModelProtocol {
    func onViewAppear()
}

class SplashViewModel: SplashViewModelProtocol {
    var serviceProvider: ServiceProviderAppDelegate
    var firRCService: FirebaseRemoteConfigServiceProtocol?
    
    private var stateCancellable: AnyCancellable?
    init(serviceProvider: ServiceProviderAppDelegate) {
        self.serviceProvider = serviceProvider
        self.firRCService = serviceProvider.getService(FirebaseRemoteConfigServiceProtocol.self)
    }
    
    func onViewAppear() {
        registerEventObserver()
        Task {
            await ATTService.shared.requestTrackingAuthorization()
        }
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
