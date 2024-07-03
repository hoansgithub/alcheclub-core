//
//  AppSession.swift
//  Example-iOS
//
//  Created by HoanNL on 23/04/2024.
//

import Foundation
import Combine
@MainActor final class AppSession: ObservableObject {
    private init() {
        //registerObservers()
    }
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
    
    private var cancellables: [AnyCancellable] = []
    @Published private(set) var appState: AppState?
    
    public func endOnboarding() {
        UserDefaults.standard.setValue(true, forKey: UserDefaultKeys.hasSeenOnboarding)
        configurateState()
    }
    
    public func loggedIn() {
        UserDefaults.standard.setValue(true, forKey: UserDefaultKeys.authenticated)
        configurateState()
    }
    
    public func loggedOut() {
        UserDefaults.standard.setValue(false, forKey: UserDefaultKeys.authenticated)
        configurateState()
    }
    
    public func reset() {
        UserDefaults.standard.setValue(false, forKey: UserDefaultKeys.hasSeenOnboarding)
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
    
    func registerObservers() {
        TeslaService.shared
            .tokenPublisher
            .sink {[weak self] res in
                if res != nil {
                    self?.loggedIn()
                } else {
                    self?.loggedOut()
                }
        }.store(in: &cancellables)
    }
}
