//
//  AdmobService.swift
//  ACCCoreAdMob
//
//  Created by HoanNL on 07/05/2024.
//

import ACCCore
import Combine
import UIKit
import GoogleMobileAds

public enum AdmobServiceError: Error {
    case canNotRequestAd
    case bannerAdLoaderNotSet
    case appOpenAdLoaderNotSet
    case interstitialAdLoaderNotSet
    case rewardedAdLoaderNotSet
    case rewaredInterstitialAdLoaderNotSet
}

public final class AdmobService: NSObject, @unchecked Sendable, AdServiceProtocol, TrackableServiceProtocol {
    public weak var eventDelegate: TrackableServiceDelegate? {
        didSet {
            self.bannerAdLoader?.eventDelegate = eventDelegate
            self.interstitialAdLoader?.eventDelegate = eventDelegate
            self.appOpenAdLoader?.eventDelegate = eventDelegate
            self.rewardedAdLoader?.eventDelegate = eventDelegate
            self.rewaredInterstitialAdLoader?.eventDelegate = eventDelegate
        }
    }
    
    //publishers
    private let stateSubject = CurrentValueSubject<ServiceState, Never>(.idle)
    public let statePublisher: AnyPublisher<ServiceState, Never>
    
    //supported ad formats
    private var canRequestAd = false
    private var bannerAdLoader: AdMobBannerAdLoader?
    private var appOpenAdLoader: AdmobAppOpenAdLoader?
    private var interstitialAdLoader: AdmobInterstitialAdLoader?
    private var rewardedAdLoader: AdmobRewardedAdLoader?
    private var rewaredInterstitialAdLoader: AdmobRewardedInterstitialAdLoader?
    //dependencies
    private var umpService: GoogleUMPServiceProtocol
    private var umpServiceCancellable: AnyCancellable?
    required public init(umpService: GoogleUMPServiceProtocol,
                         bannerAdLoader : AdMobBannerAdLoader? = nil,
                         appOpenAdLoader: AdmobAppOpenAdLoader? = nil,
                         interstitialAdLoader: AdmobInterstitialAdLoader? = nil,
                         rewardedAdLoader: AdmobRewardedAdLoader? = nil,
                         rewaredInterstitialAdLoader: AdmobRewardedInterstitialAdLoader? = nil) {
        self.umpService = umpService
        self.statePublisher = stateSubject.removeDuplicates().eraseToAnyPublisher()
        self.bannerAdLoader = bannerAdLoader
        self.appOpenAdLoader = appOpenAdLoader
        self.interstitialAdLoader = interstitialAdLoader
        self.rewardedAdLoader = rewardedAdLoader
        self.rewaredInterstitialAdLoader = rewaredInterstitialAdLoader
        super.init()
    }
    
}

extension AdmobService {
    //Banner
    public func getBannerAd(for key: String, size: ACCAdSize, root: UIViewController?) async throws -> UIView {
        guard canRequestAd else {
            throw AdmobServiceError.canNotRequestAd
        }
        guard let bannerAdLoader = bannerAdLoader else {
            throw AdmobServiceError.bannerAdLoaderNotSet
        }
        return try await bannerAdLoader.getBanner(for: key, size: size, root: root)
    }
    
    public func removeBannerAd(for key: String) -> Bool {
        return bannerAdLoader?.removeBanner(for: key) ?? false
    }
    
    //AppOpen
    public func loadAppOpenAd() async throws {
        guard canRequestAd else {
            throw AdmobServiceError.canNotRequestAd
        }
        guard let appOpenAdLoader = appOpenAdLoader else {
            throw AdmobServiceError.appOpenAdLoaderNotSet
        }
        
        try await appOpenAdLoader.loadAd()
    }
    
    @MainActor public func presentAppOpenAdIfAvailable(controller: UIViewController?, listener: FullScreenAdPresentationStateListener?) throws {
        guard let appOpenAdLoader = appOpenAdLoader else {
            throw AdmobServiceError.appOpenAdLoaderNotSet
        }
        try appOpenAdLoader.presentAdIfAvailable(controller: controller, listener: listener)
    }
    
    //Interstitial
    public func loadInterstitialAd() async throws {
        guard canRequestAd else {
            throw AdmobServiceError.canNotRequestAd
        }
        guard let interstitialAdLoader = interstitialAdLoader else {
            throw AdmobServiceError.interstitialAdLoaderNotSet
        }
        
        try await interstitialAdLoader.loadAd()
    }
    
    @MainActor public func presentInterstitialAdIfAvailable(controller: UIViewController?, listener: FullScreenAdPresentationStateListener?) throws {
        guard let interstitialAdLoader = interstitialAdLoader else {
            throw AdmobServiceError.interstitialAdLoaderNotSet
        }
        
        try interstitialAdLoader.presentAdIfAvailable(controller: controller, listener: listener)
    }
    
    //Rewared
    
    public func loadRewaredAd(options: ACCAdOptionsCollection?) async throws {
        guard canRequestAd else {
            throw AdmobServiceError.canNotRequestAd
        }
        
        guard let rewardedAdLoader = rewardedAdLoader else {
            throw AdmobServiceError.rewardedAdLoaderNotSet
        }
        
        try await rewardedAdLoader.loadAd(options: options)
    }
    
    @MainActor public func presentRewardedAdIfAvailable(controller: UIViewController?, listener: FullScreenAdPresentationStateListener?) throws {
        guard let rewardedAdLoader = rewardedAdLoader else {
            throw AdmobServiceError.rewardedAdLoaderNotSet
        }
        
        try rewardedAdLoader.presentAdIfAvailable(controller: controller, listener: listener)
    }
    
    //Rewarded Interstitial
    public func loadRewaredInterstitialAd(options: ACCAdOptionsCollection?) async throws {
        guard canRequestAd else {
            throw AdmobServiceError.canNotRequestAd
        }
        
        guard let rewaredInterstitialAdLoader = rewaredInterstitialAdLoader else {
            throw AdmobServiceError.rewaredInterstitialAdLoaderNotSet
        }
        
        try await rewaredInterstitialAdLoader.loadAd(options: options)
    }
    
    @MainActor public func presentRewaredInterstitialAdIfAvailable(controller: UIViewController?, listener: FullScreenAdPresentationStateListener?) throws {
        guard let rewaredInterstitialAdLoader = rewaredInterstitialAdLoader else {
            throw AdmobServiceError.rewaredInterstitialAdLoaderNotSet
        }
        
        try rewaredInterstitialAdLoader.presentAdIfAvailable(controller: controller, listener: listener)
    }
}

extension AdmobService: UIApplicationDelegate {
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        registerObservers { [weak self] stt in
            self?.canRequestAd = true
            self?.stateSubject.send(.ready)
        }
        
        return true
    }
}

extension AdmobService: ConfigurableProtocol {
    public func update(with config: ConfigObject) {
        
        //TODO: - UPDATE CONFIG HERE
        bannerAdLoader?.update(with: config)
        appOpenAdLoader?.update(with: config)
        interstitialAdLoader?.update(with: config)
        rewardedAdLoader?.update(with: config)
        rewaredInterstitialAdLoader?.update(with: config)
    }
}

private extension AdmobService {
    func registerObservers(completion: @escaping (_ stt: GADInitializationStatus) -> Void) {
        umpServiceCancellable?.cancel()
        umpServiceCancellable = umpService.canRequestAdsPublisher
            .filter({$0})
            .prefix(1)
            .sink { _ in
                GADMobileAds.sharedInstance().start { stt in
                    completion(stt)
                }
            }
    }
}

