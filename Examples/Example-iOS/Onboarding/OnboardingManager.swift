//
//  OnboardingManager.swift
//  Example-iOS
//
//  Created by HoanNL on 23/04/2024.
//

import Foundation

struct OnboardingItem: Identifiable, Equatable {
    var id: String
    
    var text: String
}

final class OnboardingManager: ObservableObject {
    var items : [OnboardingItem] = {
        return [
            OnboardingItem(id: UUID().uuidString, text: "PAGE 1"),
            OnboardingItem(id: UUID().uuidString, text: "PAGE 2"),
            OnboardingItem(id: UUID().uuidString, text: "PAGE 3")
        ]
    }()
}
