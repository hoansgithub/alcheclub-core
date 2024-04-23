//
//  MainViewModel.swift
//  Example-iOS
//
//  Created by HoanNL on 17/04/2024.
//

import Foundation
import ACCCore
protocol MainViewModelProtocol: BaseViewModelProtocol {
    func track(event: AnalyticsEvent)
    func login()
    func goToOnboarding()
}

class MainViewModel: MainViewModelProtocol {
    var serviceProvider: ServiceProviderAppDelegate
    init(serviceProvider: ServiceProviderAppDelegate) {
        self.serviceProvider = serviceProvider
    }
    
    func track(event: AnalyticsEvent) {
        serviceProvider.track(event: event)
    }
    
    func login() {
        AppSession.shared.login()
    }
    
    func goToOnboarding() {
        AppSession.shared.reset()
    }
    
    deinit {
        ACCLogger.print(self)
    }
    
}
