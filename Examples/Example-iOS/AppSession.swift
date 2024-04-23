//
//  AppSession.swift
//  Example-iOS
//
//  Created by HoanNL on 23/04/2024.
//

import Foundation
final class AppSession: ObservableObject {
    private init() {}
    public static let shared = AppSession()
    struct UserDefaultKeys {
        static let hasSeenOnboarding = "AppSession.UserDefaultKeys.hasSeenOnboarding"
        static let authenticated = "AppSession.UserDefaultKeys.authenticated"
    }
    
    public enum AppState {
        case onboarding
        case unauthenticated
        case authenticated
    }
    
    @Published private(set) var appState: AppState?
    
    public func endOnboarding() {
        UserDefaults.standard.setValue(true, forKey: UserDefaultKeys.hasSeenOnboarding)
        configurateState()
    }
    
    public func login() {
        UserDefaults.standard.setValue(true, forKey: UserDefaultKeys.authenticated)
        configurateState()
    }
    
    public func logout() {
        UserDefaults.standard.setValue(false, forKey: UserDefaultKeys.authenticated)
        configurateState()
    }
    
    public func reset() {
        UserDefaults.standard.setValue(false, forKey: UserDefaultKeys.hasSeenOnboarding)
        UserDefaults.standard.setValue(false, forKey: UserDefaultKeys.authenticated)
        configurateState()
    }
    
    public func configurateState() {
        let onboardingSeen = UserDefaults.standard.bool(forKey: UserDefaultKeys.hasSeenOnboarding)
        let authenticated = UserDefaults.standard.bool(forKey: UserDefaultKeys.authenticated)
        if onboardingSeen {
            appState = authenticated ? .authenticated : .unauthenticated
        } else {
            appState = .onboarding
        }
    }
}
