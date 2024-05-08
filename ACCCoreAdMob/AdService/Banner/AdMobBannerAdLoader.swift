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
    private var defaultSize: ACCAdSize
    private var bannersCollection: [String: GADBannerView] = [:]
    public required init(adUnitID: String, defaultSize: ACCAdSize) {
        self.adUnitID = adUnitID
        self.defaultSize = defaultSize
        super.init()
    }
    
    public func update(with config: ConfigObject) {
        
    }
    
    @MainActor public func getBanner(for key: String, size: ACCAdSize?, root: UIViewController?) throws -> UIView {
        if let storedBanner = bannersCollection[key] {
            return storedBanner
        }
        
        let adSize = {
            if let size = size { return size }
            return defaultSize
        }()
        
        let gadAdSize = GADAdSize.from(size: adSize)
        let gadBannerView = GADBannerView(adSize: gadAdSize)
        gadBannerView.rootViewController = root
        gadBannerView.delegate = self
        gadBannerView.load(GADRequest())
        bannersCollection[key] = gadBannerView
        return gadBannerView
    }
}

extension AdMobBannerAdLoader: GADBannerViewDelegate {
    public func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        if let bannerElement = bannersCollection.first (where: { $0.value == bannerView }) {
            bannersCollection.removeValue(forKey: bannerElement.key)
        }
    }
}
