//
//  AdmobAppOpenAdLoader.swift
//  ACCCoreAdMob
//
//  Created by HoanNL on 14/05/2024.
//

import ACCCore
import UIKit
import GoogleMobileAds

public final class AdmobAppOpenAdLoader: AdmobFullScreenAdLoader {
    
    /*
     Important: App open ads will time out after four hours. Ads rendered more than four hours after request time will no longer be valid and may not earn revenue.
     https://developers.google.com/admob/ios/app-open#consider_ad_expiration
     */
    //Timeout handling
    private var loadTime: Date?
    private let fourHoursInSeconds = TimeInterval(3600 * 4)
    //AppOpen
    private var appOpenAd: GADAppOpenAd?
    
    internal func loadAd() async throws {
        // Do not load ad if there is an unused ad or one is already loading.
        if isLoadingAd {
            throw FullScreenAdLoaderError.adIsBeingLoaded
        }
        
        if isAdAvailable() {
            throw FullScreenAdLoaderError.adIsAlreadyLoaded
        }
        isLoadingAd = true
        
        do {
            appOpenAd = try await GADAppOpenAd.load(
                withAdUnitID: adUnitID, request: GADRequest())
            appOpenAd?.fullScreenContentDelegate = self
            loadTime = Date()
        } catch {
            isLoadingAd = false
            throw FullScreenAdLoaderError.adFailedToLoad(projectedError: error)
        }
        
        isLoadingAd = false
    }
    
    public override func update(with config: ConfigContainer) {
        //TODO: -Update ad config here
    }
    
    public override func presentAdIfAvailable(controller: UIViewController?, listener: FullScreenAdPresentationStateListener?) throws {
        try super.presentAdIfAvailable(controller: controller, listener: listener)
        
        appOpenAd?.present(fromRootViewController: controller)
    }
}

public extension AdmobAppOpenAdLoader {
    override func isAdAvailable() -> Bool {
        // Check if ad exists and can be shown.
        return appOpenAd != nil && wasLoadTimeLessThanFourHoursAgo()
    }
    
    private func wasLoadTimeLessThanFourHoursAgo() -> Bool {
        guard let loadTime = loadTime else { return false }
        // Check if ad was loaded more than four hours ago.
        return Date().timeIntervalSince(loadTime) < fourHoursInSeconds
    }
    
    override func resetState() {
        appOpenAd = nil
        super.resetState()
    }

}
