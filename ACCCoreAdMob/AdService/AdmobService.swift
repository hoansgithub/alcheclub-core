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
}

public final class AdmobService: NSObject, AdServiceProtocol, TrackableServiceProtocol {
    public weak var eventDelegate: TrackableServiceDelegate? {
        didSet {
            self.bannerAdLoader?.eventDelegate = eventDelegate
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
    
    //dependencies
    private var umpService: GoogleUMPServiceProtocol
    private var umpServiceCancellable: AnyCancellable?
    required public init(umpService: GoogleUMPServiceProtocol,
                         bannerAdLoader : AdMobBannerAdLoader? = nil,
                         appOpenAdLoader: AdmobAppOpenAdLoader? = nil,
                         interstitialAdLoader: AdmobInterstitialAdLoader? = nil) {
        self.umpService = umpService
        self.statePublisher = stateSubject.removeDuplicates().eraseToAnyPublisher()
        self.bannerAdLoader = bannerAdLoader
        self.appOpenAdLoader = appOpenAdLoader
        self.interstitialAdLoader = interstitialAdLoader
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
    
    public func showAppOpenAdIfAvailable(controller: UIViewController?, listener: FullScreenAdPresentationStateListener?) throws {
        guard let appOpenAdLoader = appOpenAdLoader else {
            throw AdmobServiceError.appOpenAdLoaderNotSet
        }
        try appOpenAdLoader.showAdIfAvailable(controller: controller, listener: listener)
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
    
    public func showInterstitialAdIfAvailable(controller: UIViewController?, listener: FullScreenAdPresentationStateListener?) throws {
        guard let interstitialAdLoader = interstitialAdLoader else {
            throw AdmobServiceError.interstitialAdLoaderNotSet
        }
        
        try interstitialAdLoader.showAdIfAvailable(controller: controller, listener: listener)
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

extension GADInitializationStatus: @unchecked Sendable {}
