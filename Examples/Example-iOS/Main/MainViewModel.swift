//
//  MainViewModel.swift
//  Example-iOS
//
//  Created by HoanNL on 17/04/2024.
//

import Foundation
import ACCCore
import ACCCoreFirebase
import Combine
import UIKit
import ACCCoreStoreKit
protocol MainViewModelProtocol: Sendable, BaseViewModelProtocol, StoreEnabledViewModel {
    func track(event: AnalyticsEvent)
    func login() async
    func goToOnboarding() async
    
    var notificationPermissionNeeded: Bool { get set }
    var notiUserInfo: [AnyHashable: Any] { get }
    var notiToken: String { get }
    var storeActive: Bool { get set }
    func requestNotiPermission()
}

class MainViewModel: @unchecked Sendable, MainViewModelProtocol {
    
    var defaultStoreConfig: StoreViewModelConfig {
        StorePreset.shared.defaultConfig
    }
    
    @Published var notificationPermissionNeeded: Bool = true
    @Published var notiUserInfo: [AnyHashable: Any] = [:]
    @Published var notiToken: String = ""
    @Published var storeViewModel: StoreViewModelProtocol?
    @Published var storeActive: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    private var firebaseMessageService: FirebaseMessagingServiceProtocol?
    internal var storeService: StoreServiceProtocol?
    init() {
        self.firebaseMessageService = ACCApp.getService(FirebaseMessagingServiceProtocol.self)
        self.storeService = ACCApp.getService(StoreServiceProtocol.self)
        registerObservers()
    }
    
    func track(event: AnalyticsEvent) {
        ACCApp.track(event: event)
    }
    
    @MainActor func login() async {
//        AppSession.shared.login()
        await _ = TeslaService.shared.requestOAuth()
    }
    
    @MainActor func goToOnboarding() {
        AppSession.shared.reset()
    }
    
    func requestNotiPermission() {
        Task {
            if let status = await firebaseMessageService?.getPermissionStatus() {
                switch status {
                case .notDetermined:
                    Task {
                        try await firebaseMessageService?.registerForRemoteNotifications()
                    }
                case .authorized: break
                    //do nothing
                default:
                    // go to settings
                    Task { @MainActor in
                        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                            await UIApplication.shared.open(settingsURL)
                        }
                    }
                }
            }
        }
    }
    
    deinit {
        ACCLogger.print(self)
    }
    
}

extension MainViewModel {
    func registerObservers() {
        firebaseMessageService?.authStatusPublisher
            .receive(on: RunLoop.main)
            .sink(receiveValue: {[weak self] status in
                self?.notificationPermissionNeeded = status != .authorized
            }).store(in: &cancellables)
        
        firebaseMessageService?.responseUserInfoPublisher
            .sink(receiveValue: {[weak self] val in
                self?.notiUserInfo = val
            }).store(in: &cancellables)
        
        firebaseMessageService?.tokenPublisher
            .sink(receiveValue: {[weak self] val in
                self?.notiToken = val
            }).store(in: &cancellables)
        
    }
}
