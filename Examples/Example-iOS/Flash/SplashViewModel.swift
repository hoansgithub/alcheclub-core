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
    
    private var cancellables = Set<AnyCancellable>()
    init(serviceProvider: ServiceProviderAppDelegate) {
        self.serviceProvider = serviceProvider
        self.firRCService = serviceProvider.getService(FirebaseRemoteConfigServiceProtocol.self)
    }
    
    func onViewAppear() {
        registerEventObserver()
    }
    
    deinit {
        ACCLogger.print(self)
    }
}

private extension SplashViewModel {
    func registerEventObserver() {
        firRCService?.statePublisher.filter({$0 == .ready}).prefix(1).timeout(.seconds(5), scheduler: DispatchQueue.main).sink(receiveValue: { state in
            AppSession.shared.configurateState()
        }).store(in: &cancellables)
    }
}
