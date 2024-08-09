//
//  AdMobBannerAdLoader.swift
//  ACCCoreAdMob
//
//  Created by HoanNL on 08/05/2024.
//

import ACCCore
import UIKit
import GoogleMobileAds
public final class AdMobBannerAdLoader: NSObject, @unchecked Sendable, BannerAdLoader {
    
    public typealias BannerAdLoaderErrorHandler = (@Sendable (_ error: Error) -> Void)
    public weak var eventDelegate: TrackableServiceDelegate?
    public var adUnitIDs: [String] = []
    private var bannersCollection: [String: GADBannerView] = [:]
    private var errorHandler: BannerAdLoaderErrorHandler?
    public required init(adUnitIDs: [String]) {
        self.adUnitIDs = adUnitIDs
        super.init()
    }
    
    public func update(with config: ConfigContainer) {
        //TODO: -Update banner ad config here
    }
    
    @MainActor internal func getBanner(for key: String,unitID: String , size: ACCAdSize, root: UIViewController?, errorHandler:  BannerAdLoaderErrorHandler?) throws -> UIView {
        self.errorHandler = nil
        if let storedBanner = bannersCollection[key] {
            return storedBanner
        }
        
        guard let adUnitID = adUnitIDs.first(where: {$0 == unitID}) else {
            ACCLogger.print("Banner AdUnit not found \(unitID)")
            throw AdmobServiceError.adUnitNotFound
        }
        self.errorHandler = errorHandler
        let gadAdSize = GADAdSize.from(size: size)
        let gadBannerView = GADBannerView(adSize: gadAdSize)
        gadBannerView.adUnitID = adUnitID
        gadBannerView.rootViewController = root
        gadBannerView.delegate = self
        gadBannerView.load(GADRequest())
        bannersCollection[key] = gadBannerView
        return gadBannerView
    }
    
    internal func removeBanner(for key: String) -> Bool {
        return bannersCollection.removeValue(forKey: key) != nil
    }
}

extension AdMobBannerAdLoader: GADBannerViewDelegate {
    public func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        //TODO: -Track banner related events
        //ACCLogger.print(bannerView)
    }
    
    public func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        ACCLogger.print(error.localizedDescription, level: .error)
        if let bannerElement = bannersCollection.first (where: { $0.value == bannerView }) {
            bannersCollection.removeValue(forKey: bannerElement.key)
        }
        errorHandler?(error)
    }
    
    public func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
        //ACCLogger.print(bannerView)
        //track(event: AnalyticsEvent("banner_impression"))
    }
    
    public func bannerViewDidRecordClick(_ bannerView: GADBannerView) {
        //ACCLogger.print(bannerView)
    }
    
    public func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
        //ACCLogger.print(bannerView)
    }
    
    public func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
        //ACCLogger.print(bannerView)
    }
    
    public func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
        //ACCLogger.print(bannerView)
    }
    
}
