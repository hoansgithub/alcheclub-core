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
public final class AdmobService: NSObject, AdServiceProtocol, TrackableServiceProtocol {
    public weak var eventDelegate: TrackableServiceDelegate?
    
    //publishers
    private let stateSubject = CurrentValueSubject<ServiceState, Never>(.idle)
    public let statePublisher: AnyPublisher<ServiceState, Never>
    
    //supported ad formats
    public private(set) var bannerAdLoader: BannerAdLoaderProtocol?
    
    //dependencies
    private var umpService: GoogleUMPServiceProtocol
    private var umpServiceCancellable: AnyCancellable?
    required public init(umpService: GoogleUMPServiceProtocol,
                         bannerAdLoader : BannerAdLoaderProtocol? = nil) {
        self.umpService = umpService
        self.statePublisher = stateSubject.removeDuplicates().eraseToAnyPublisher()
        self.bannerAdLoader = bannerAdLoader
        super.init()
    }
    
}

extension AdmobService: UIApplicationDelegate {
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        registerObservers { [weak self] stt in
            self?.stateSubject.send(.ready)
            
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
