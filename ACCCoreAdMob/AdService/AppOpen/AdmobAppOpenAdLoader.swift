//
//  AdmobAppOpenAdLoader.swift
//  ACCCoreAdMob
//
//  Created by HoanNL on 14/05/2024.
//

import ACCCore
import UIKit
import GoogleMobileAds

public final class AdmobAppOpenAdLoader: NSObject, AppOpenAdLoaderProtocol {
    
    /*
     Important: App open ads will time out after four hours. Ads rendered more than four hours after request time will no longer be valid and may not earn revenue.
     https://developers.google.com/admob/ios/app-open#consider_ad_expiration
     */
    //Timeout handling
    private var loadTime: Date?
    private let fourHoursInSeconds = TimeInterval(3600 * 4)
    //AppOpen
    var appOpenAd: GADAppOpenAd?
    var isLoadingAd = false
    var isShowingAd = false
    //Full screen state
    private var presentationStateListener: FullScreenAdPresentationStateListener?
    
    //required properties
    public weak var eventDelegate: TrackableServiceDelegate?
    public var adUnitID: String = ""
    public required init(adUnitID: String) {
        self.adUnitID = adUnitID
        super.init()
    }
    
    
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
}

public extension AdmobAppOpenAdLoader {
    func update(with config: ConfigObject) {
        //TODO: -Update ad config here
    }
    
    func showAdIfAvailable(controller: UIViewController?, listener: FullScreenAdPresentationStateListener?) throws {
        // If the app open ad is already showing, do not show the ad again.
        guard !isShowingAd else {
            throw FullScreenAdLoaderError.adIsBeingShown
        }
        
        // If the app open ad is not available yet but is supposed to show, load
        // a new ad.
        if !isAdAvailable() {
            throw FullScreenAdLoaderError.adIsNotAvailable
        }
        
        if let ad = appOpenAd {
            presentationStateListener = listener
            isShowingAd = true
            ad.present(fromRootViewController: controller)
        }
    }
}

extension AdmobAppOpenAdLoader: GADFullScreenContentDelegate {
    public func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
        
    }
    
    public func adDidRecordClick(_ ad: GADFullScreenPresentingAd) {
        
    }
    
    public func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        presentationStateListener?(.failedToPresent(error: error))
        resetListener()
    }
    
    public func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        presentationStateListener?(.willPresent)
    }
    
    public func adWillDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        presentationStateListener?(.willDismiss)
    }
    
    public func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        presentationStateListener?(.didDismiss)
        resetListener()
    }
}

private extension AdmobAppOpenAdLoader {
    func isAdAvailable() -> Bool {
        // Check if ad exists and can be shown.
        return appOpenAd != nil && wasLoadTimeLessThanFourHoursAgo()
    }
    
    private func wasLoadTimeLessThanFourHoursAgo() -> Bool {
        guard let loadTime = loadTime else { return false }
        // Check if ad was loaded more than four hours ago.
        return Date().timeIntervalSince(loadTime) < fourHoursInSeconds
    }
    
    
    func resetListener() {
        appOpenAd = nil
        isShowingAd = false
        presentationStateListener = nil
    }
}
