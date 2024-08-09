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
    case rewardedInterstitialAdLoaderNotSet
    case adUnitNotFound
}

public final class AdmobService: NSObject, @unchecked Sendable, AdService, TrackableService {
    public weak var eventDelegate: TrackableServiceDelegate? {
        didSet {
            self.bannerAdLoader?.eventDelegate = eventDelegate
            self.interstitialAdLoader?.eventDelegate = eventDelegate
            self.appOpenAdLoader?.eventDelegate = eventDelegate
            self.rewardedAdLoader?.eventDelegate = eventDelegate
            self.rewardedInterstitialAdLoader?.eventDelegate = eventDelegate
            self.nativeAdLoader?.eventDelegate = eventDelegate
            
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
    private var rewardedInterstitialAdLoader: AdmobRewardedInterstitialAdLoader?
    private var nativeAdLoader: AdmobNativeAdLoader?
    //dependencies
    private var umpService: GoogleUMPServiceProtocol
    private var umpServiceCancellable: AnyCancellable?
    required public init(umpService: GoogleUMPServiceProtocol,
                         bannerAdLoader : AdMobBannerAdLoader? = nil,
                         appOpenAdLoader: AdmobAppOpenAdLoader? = nil,
                         interstitialAdLoader: AdmobInterstitialAdLoader? = nil,
                         rewardedAdLoader: AdmobRewardedAdLoader? = nil,
                         rewardedInterstitialAdLoader: AdmobRewardedInterstitialAdLoader? = nil,
                         nativeAdLoader: AdmobNativeAdLoader? = nil) {
        self.umpService = umpService
        self.statePublisher = stateSubject.removeDuplicates().eraseToAnyPublisher()
        self.bannerAdLoader = bannerAdLoader
        self.appOpenAdLoader = appOpenAdLoader
        self.interstitialAdLoader = interstitialAdLoader
        self.rewardedAdLoader = rewardedAdLoader
        self.rewardedInterstitialAdLoader = rewardedInterstitialAdLoader
        self.nativeAdLoader = nativeAdLoader
        super.init()
    }
    
}

extension AdmobService {
    //Banner
    public func getBannerAd(for key: String, unitID: String, size: ACCAdSize, root: UIViewController?, errorHandler: AdMobBannerAdLoader.BannerAdLoaderErrorHandler?) async throws -> UIView {
        guard canRequestAd else {
            throw AdmobServiceError.canNotRequestAd
        }
        guard let bannerAdLoader = bannerAdLoader else {
            throw AdmobServiceError.bannerAdLoaderNotSet
        }
        return try await bannerAdLoader.getBanner(for: key, unitID: unitID, size: size, root: root, errorHandler: errorHandler)
    }
    
    public func removeBannerAd(for key: String) -> Bool {
        return bannerAdLoader?.removeBanner(for: key) ?? false
    }
    
    //AppOpen
    public func loadAppOpenAd(unitID: String) async throws {
        guard canRequestAd else {
            throw AdmobServiceError.canNotRequestAd
        }
        guard let appOpenAdLoader = appOpenAdLoader else {
            throw AdmobServiceError.appOpenAdLoaderNotSet
        }
        
        try await appOpenAdLoader.loadAd(unitID: unitID)
    }
    
    @MainActor public func presentAppOpenAdIfAvailable(controller: UIViewController?, listener: FullScreenAdPresentationStateListener?) throws {
        guard let appOpenAdLoader = appOpenAdLoader else {
            throw AdmobServiceError.appOpenAdLoaderNotSet
        }
        try appOpenAdLoader.presentAdIfAvailable(controller: controller, listener: listener)
    }
    
    //Interstitial
    public func loadInterstitialAd(unitID: String) async throws {
        guard canRequestAd else {
            throw AdmobServiceError.canNotRequestAd
        }
        guard let interstitialAdLoader = interstitialAdLoader else {
            throw AdmobServiceError.interstitialAdLoaderNotSet
        }
        
        try await interstitialAdLoader.loadAd(unitID: unitID)
    }
    
    @MainActor public func presentInterstitialAdIfAvailable(controller: UIViewController?, listener: FullScreenAdPresentationStateListener?) throws {
        guard let interstitialAdLoader = interstitialAdLoader else {
            throw AdmobServiceError.interstitialAdLoaderNotSet
        }
        
        try interstitialAdLoader.presentAdIfAvailable(controller: controller, listener: listener)
    }
    
    //Rewared
    
    public func loadRewardedAd(unitID: String ,options: ACCAdOptionsCollection?) async throws {
        guard canRequestAd else {
            throw AdmobServiceError.canNotRequestAd
        }
        
        guard let rewardedAdLoader = rewardedAdLoader else {
            throw AdmobServiceError.rewardedAdLoaderNotSet
        }
        
        try await rewardedAdLoader.loadAd(unitID: unitID ,options: options)
    }
    
    @MainActor public func presentRewardedAdIfAvailable(controller: UIViewController?, listener: FullScreenAdPresentationStateListener?) throws {
        guard let rewardedAdLoader = rewardedAdLoader else {
            throw AdmobServiceError.rewardedAdLoaderNotSet
        }
        
        try rewardedAdLoader.presentAdIfAvailable(controller: controller, listener: listener)
    }
    
    //Rewarded Interstitial
    public func loadRewardedInterstitialAd(unitID: String ,options: ACCAdOptionsCollection?) async throws {
        guard canRequestAd else {
            throw AdmobServiceError.canNotRequestAd
        }
        
        guard let rewardedInterstitialAdLoader = rewardedInterstitialAdLoader else {
            throw AdmobServiceError.rewardedInterstitialAdLoaderNotSet
        }
        
        try await rewardedInterstitialAdLoader.loadAd(unitID: unitID,options: options)
    }
    
    @MainActor public func presentRewardedInterstitialAdIfAvailable(controller: UIViewController?, listener: FullScreenAdPresentationStateListener?) throws {
        guard let rewardedInterstitialAdLoader = rewardedInterstitialAdLoader else {
            throw AdmobServiceError.rewardedInterstitialAdLoaderNotSet
        }
        
        try rewardedInterstitialAdLoader.presentAdIfAvailable(controller: controller, listener: listener)
    }
    
    @MainActor public func getNativeAds(for key: String,unitID: String , root: UIViewController?, receiver: NativeAdReceiver?) {
        nativeAdLoader?.getNativeAd(for: key, unitID: unitID, root: root, adReceiver: receiver)
    }
    
    public func removeNativeAds(for key: String) -> Bool {
        return nativeAdLoader?.removeNativeAds(for: key) ?? false
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

extension AdmobService: ConfigurableObject {
    public func update(with config: ConfigContainer) {
        
        //TODO: - UPDATE CONFIG HERE
        bannerAdLoader?.update(with: config)
        appOpenAdLoader?.update(with: config)
        interstitialAdLoader?.update(with: config)
        rewardedAdLoader?.update(with: config)
        rewardedInterstitialAdLoader?.update(with: config)
        nativeAdLoader?.update(with: config)
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

