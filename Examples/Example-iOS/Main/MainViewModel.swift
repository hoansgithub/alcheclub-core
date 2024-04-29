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
protocol MainViewModelProtocol: BaseViewModelProtocol {
    func track(event: AnalyticsEvent)
    func login()
    func goToOnboarding()
    
    var notificationPermissionNeeded: Bool { get set }
    func requestNotiPermission()
}

class MainViewModel: @unchecked Sendable, MainViewModelProtocol {
    var serviceProvider: ServiceProviderAppDelegate
    @Published var notificationPermissionNeeded: Bool = true
    
    private var cancellables = Set<AnyCancellable>()
    private var firebaseMessageService: FirebaseMessagingServiceProtocol?
    init(serviceProvider: ServiceProviderAppDelegate) {
        self.serviceProvider = serviceProvider
        self.firebaseMessageService = serviceProvider.getService(FirebaseMessagingServiceProtocol.self)
        registerObservers()
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
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: {[weak self] status in
                self?.notificationPermissionNeeded = status != .authorized
            }).store(in: &cancellables)
    }
}
