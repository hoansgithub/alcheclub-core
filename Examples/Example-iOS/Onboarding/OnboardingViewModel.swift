//
//  OnboardingViewModel.swift
//  Example-iOS
//
//  Created by HoanNL on 23/04/2024.
//

import ACCCore
protocol OnboardingViewModelProtocol: BaseViewModelProtocol {
    func closeOnboarding()
}

class OnboardingViewModel: OnboardingViewModelProtocol {
    init() {
    }
    
    func closeOnboarding() {
        AppSession.shared.endOnboarding()
    }
    
    deinit {
        ACCLogger.print(self)
    }
}
