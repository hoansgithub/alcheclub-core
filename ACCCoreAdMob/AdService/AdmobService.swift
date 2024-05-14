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
    
    //dependencies
    private var umpService: GoogleUMPServiceProtocol
    private var umpServiceCancellable: AnyCancellable?
    required public init(umpService: GoogleUMPServiceProtocol,
                         bannerAdLoader : AdMobBannerAdLoader? = nil) {
        self.umpService = umpService
        self.statePublisher = stateSubject.removeDuplicates().eraseToAnyPublisher()
        self.bannerAdLoader = bannerAdLoader
        super.init()
    }
    
}

extension AdmobService {
    //Banner
    public func getBanner(for key: String, size: ACCAdSize, root: UIViewController?) async throws -> UIView {
        guard canRequestAd else {
            throw AdmobServiceError.canNotRequestAd
        }
        guard let bannerAdLoader = bannerAdLoader else {
            throw AdmobServiceError.bannerAdLoaderNotSet
        }
        return try await bannerAdLoader.getBanner(for: key, size: size, root: root)
    }
    
    public func removeBanner(for key: String) -> Bool {
        return bannerAdLoader?.removeBanner(for: key) ?? false
    }
}

extension AdmobService: UIApplicationDelegate {
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        registerObservers { [weak self] stt in
            self?.stateSubject.send(.ready)
            self?.canRequestAd = true
        }
        
        return true
    }
}

extension AdmobService: ConfigurableProtocol {
    public func update(with config: ConfigObject) {
        
        //TODO: - UPDATE CONFIG HERE
        bannerAdLoader?.update(with: config)
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
