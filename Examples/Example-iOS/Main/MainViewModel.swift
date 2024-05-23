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
protocol MainViewModelProtocol: Sendable, BaseViewModelProtocol {
    func track(event: AnalyticsEvent)
    func login() async
    func goToOnboarding() async
    
    var notificationPermissionNeeded: Bool { get set }
    var notiUserInfo: [AnyHashable: Any] { get }
    var notiToken: String { get }
    func requestNotiPermission()
}

class MainViewModel: @unchecked Sendable, MainViewModelProtocol {
    @Published var notificationPermissionNeeded: Bool = true
    @Published var notiUserInfo: [AnyHashable: Any] = [:]
    @Published var notiToken: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    private var firebaseMessageService: FirebaseMessagingServiceProtocol?
    init() {
        self.firebaseMessageService = ACCApp.getService(FirebaseMessagingServiceProtocol.self)
        registerObservers()
    }
    
    func track(event: AnalyticsEvent) {
        ACCApp.track(event: event)
    }
    
    @MainActor func login() {
        AppSession.shared.login()
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
