//
//  AdsViewModel.swift
//  Example-iOS
//
//  Created by HoanNL on 02/05/2024.
//

import Foundation
import ACCCore
import UIKit
import ACCCoreAdMob
import Combine
protocol AdsViewModelProtocol: BaseViewModelProtocol {
    var recentBannerAdView: UIView? { get set }
    var isPrivacyOptionsRequired: Bool { get }
    var canRequestAds: Bool { get }
    func presentPrivacyOptions(from view: UIViewController)
    
    func reset()
}

class AdsViewModel: @unchecked Sendable, AdsViewModelProtocol {
    @Published var recentBannerAdView: UIView?
    @Published var isPrivacyOptionsRequired = false
    @Published var canRequestAds: Bool = false
    
    var serviceProvider: ServiceProviderAppDelegate
    var umpService: GoogleUMPServiceProtocol?
    var cancellables = Set<AnyCancellable>()
    init(serviceProvider: ServiceProviderAppDelegate) {
        self.serviceProvider = serviceProvider
        self.umpService = serviceProvider.getService(GoogleUMPServiceProtocol.self)
        registerPublishers()
    }
    
    deinit {
        ACCLogger.print(self)
    }
    
}

extension AdsViewModel {
    func presentPrivacyOptions(from view: UIViewController) {
        Task {
            do {
                try await umpService?.presentPrivacyOptionsForm(from: view)
            } catch {
                ACCLogger.print(error.localizedDescription, level: .error)
            }
        }
    }
    
    func registerPublishers() {
        umpService?.isPrivacyOptionsRequiredPublisher
            .sink(receiveValue: {[weak self] required in
                self?.isPrivacyOptionsRequired = required
            }).store(in: &cancellables)
        
        umpService?.canRequestAdsPublisher
            .sink(receiveValue: {[weak self] can in
                self?.canRequestAds = can
                ACCLogger.print(can)
            }).store(in: &cancellables)
    }
    
    func reset() {
#if DEBUG
        umpService?.reset()
#endif
    }
}
