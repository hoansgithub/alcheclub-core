//
//  AdMobBannerAdLoader.swift
//  ACCCoreAdMob
//
//  Created by HoanNL on 08/05/2024.
//

import ACCCore
import UIKit
import GoogleMobileAds
public final class AdMobBannerAdLoader: NSObject, BannerAdLoaderProtocol {
    public weak var eventDelegate: TrackableServiceDelegate?
    public var adUnitID: String = ""
    private var bannersCollection: [String: GADBannerView] = [:]
    public required init(adUnitID: String) {
        self.adUnitID = adUnitID
        super.init()
    }
    
    public func update(with config: ConfigObject) {
        
    }
    
    @MainActor internal func getBanner(for key: String, size: ACCAdSize, root: UIViewController?) throws -> UIView {
        if let storedBanner = bannersCollection[key] {
            return storedBanner
        }
        
        
        let gadAdSize = GADAdSize.from(size: size)
        let gadBannerView = GADBannerView(adSize: gadAdSize)
        gadBannerView.adUnitID = adUnitID
        gadBannerView.rootViewController = root
        gadBannerView.delegate = self
        gadBannerView.load(GADRequest())
        bannersCollection[key] = gadBannerView
        return gadBannerView
    }
}

extension AdMobBannerAdLoader: GADBannerViewDelegate {
    public func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        ACCLogger.print(bannerView)
    }
    
    public func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        ACCLogger.print(error.localizedDescription, level: .error)
        if let bannerElement = bannersCollection.first (where: { $0.value == bannerView }) {
            bannersCollection.removeValue(forKey: bannerElement.key)
        }
    }
    
    public func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
        ACCLogger.print(bannerView)
    }
    
    public func bannerViewDidRecordClick(_ bannerView: GADBannerView) {
        ACCLogger.print(bannerView)
    }
    
    public func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
        ACCLogger.print(bannerView)
    }
    
    public func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
        ACCLogger.print(bannerView)
    }
    
    public func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
        ACCLogger.print(bannerView)
    }
    
}
