//
//  OnboardingViewModel.swift
//  Example-iOS
//
//  Created by HoanNL on 23/04/2024.
//

import ACCCore
protocol OnboardingViewModelProtocol: Sendable, BaseViewModelProtocol {
    func closeOnboarding() async
}

final class OnboardingViewModel: OnboardingViewModelProtocol {
    init() {
    }
    
    @MainActor func closeOnboarding() {
        AppSession.shared.endOnboarding()
    }
    
    deinit {
        ACCLogger.print(self)
    }
}
