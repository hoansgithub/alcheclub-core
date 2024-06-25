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
protocol AdsViewModelProtocol: Sendable, BaseViewModelProtocol {
    var recentBannerAdView: UIView? { get set }
    var recentNativeAdView: UIView? { get set }
    var isPrivacyOptionsRequired: Bool { get }
    var canRequestAds: Bool { get }
    var adMobReady: Bool { get }
    func presentPrivacyOptions(from view: UIViewController)
    func getBannerAd(controller: UIViewController) async
    func removeBannerAd()
    @MainActor func presentInterstitial(from view: UIViewController?, listener: FullScreenAdPresentationStateListener?) throws
    @MainActor func presentRewarded(from view: UIViewController?, listener: FullScreenAdPresentationStateListener?) throws
    @MainActor func presentRewardedInterstitial(from view: UIViewController?, listener: FullScreenAdPresentationStateListener?) throws
    @MainActor func getNativeAd(for key: String, root: UIViewController?)
    func removeNativeAds(for key: String)
    func reset()
}

class AdsViewModel: @unchecked Sendable, AdsViewModelProtocol {
    @Published var recentBannerAdView: UIView?
    @Published var recentNativeAdView: UIView?
    @Published var isPrivacyOptionsRequired = false
    @Published var canRequestAds: Bool = false
    @Published var adMobReady: Bool = false
    
    var umpService: GoogleUMPServiceProtocol?
    var admobService: AdServiceProtocol?
    var cancellables = Set<AnyCancellable>()
    private var nativeAdReceiver: NativeAdReceiver?
    public init() {
        self.umpService = ACCApp.getService(GoogleUMPServiceProtocol.self)
        self.admobService = ACCApp.getService(AdServiceProtocol.self)
        self.registerPublishers()
    }
    
    deinit {
        ACCLogger.print(self)
    }
    
}

extension AdsViewModel {
    
    @MainActor func getNativeAd(for key: String, root: UIViewController?) {
        
        nativeAdReceiver = NativeAdReceiver(templateGetter: {
            let nibView = Bundle.main.loadNibNamed("NativeAdView", owner: nil, options: nil)?.first
            return nibView as? BaseGADNativeAdview
            
        }, adViewReceiver: { [weak self] view in
            self?.recentNativeAdView = view.first
        })
        
        admobService?.getNativeAds(for: key, root: root, receiver: nativeAdReceiver)
    }
    
    @MainActor func presentInterstitial(from view: UIViewController?, listener: FullScreenAdPresentationStateListener?) throws {
        //        let allScenes = UIApplication.shared.connectedScenes
        //        let scene = allScenes.first { $0.activationState == .foregroundActive }
        //        let windowScene = scene as? UIWindowScene
        //        let root = windowScene?.keyWindow?.rootViewController
        
        try admobService?.presentInterstitialAdIfAvailable(controller: view, listener: { [weak self] state in
            switch state {
            case .didDismiss:
                Task {
                    try? await self?.admobService?.loadInterstitialAd()
                }
            default: break
            }
            
            listener?(state)
        })
    }
    
    @MainActor func presentRewarded(from view: UIViewController?, listener: FullScreenAdPresentationStateListener?) throws {
        try admobService?.presentRewardedAdIfAvailable(controller: view, listener: {[weak self] state in
            switch state {
            case .didDismiss:
                Task {
                    try? await self?.admobService?.loadRewardedAd(options: nil)
                }
                
            default:
                break
            }
            
            listener?(state)
        })
    }
    
    @MainActor func presentRewardedInterstitial(from view: UIViewController?, listener: FullScreenAdPresentationStateListener?) throws {
        try admobService?.presentRewardedInterstitialAdIfAvailable(controller: view, listener: {[weak self] state in
            switch state {
            case .didDismiss:
                Task {
                    try? await self?.admobService?.loadRewardedInterstitialAd(options: nil)
                }
                
            default:
                break
            }
            
            listener?(state)
        })
    }
    
    func removeBannerAd() {
        Task { @MainActor in
            if admobService?.removeBannerAd(for: "AdsViewModel") == true {
                recentBannerAdView = nil
            }
        }
    }
    
    func removeNativeAds(for key: String) {
        if admobService?.removeNativeAds(for: key) == true {
            recentNativeAdView = nil
        }
    }
    
    @MainActor func getBannerAd(controller: UIViewController) {
        Task {
            do {
                let scenes = UIApplication.shared.connectedScenes
                let windowScene = scenes.first(where: {$0 is UIWindowScene}) as? UIWindowScene
                let window = windowScene?.windows.first
                let sceneWidth = window?.frame.width ?? 0
                
                let banner = try await admobService?.getBannerAd(for: "AdsViewModel", size: .currentAnchoredAdaptiveBanner(width: sceneWidth), root: controller)
                recentBannerAdView = banner
            }
            catch {
                ACCLogger.print(error.localizedDescription)
            }
        }
    }
    
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
            }).store(in: &cancellables)
        
        admobService?.statePublisher.filter({$0 == .ready})
            .sink(receiveValue: { [weak self] _ in
                self?.adMobReady = true
            }).store(in: &cancellables)
    }
    
    func reset() {
#if DEBUG
        umpService?.reset()
#endif
    }
}
