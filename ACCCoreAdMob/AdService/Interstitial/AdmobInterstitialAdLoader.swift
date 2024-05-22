//
//  AdmobInterstitialAdLoader.swift
//  ACCCoreAdMob
//
//  Created by HoanNL on 21/05/2024.
//

import ACCCore
import UIKit
import GoogleMobileAds

public final class AdmobInterstitialAdLoader: NSObject, InterstitialAdLoaderProtocol {
    //State
    private var interstitialAd: GADInterstitialAd?
    private var isLoadingAd = false
    private var isShowingAd = false
    
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
            interstitialAd = try await GADInterstitialAd.load(withAdUnitID: adUnitID, request: GADRequest())
            interstitialAd?.fullScreenContentDelegate = self
        } catch {
            isLoadingAd = false
            throw FullScreenAdLoaderError.adFailedToLoad(projectedError: error)
        }
        
        isLoadingAd = false
    }
    
}

public extension AdmobInterstitialAdLoader {
    func update(with config: ConfigObject) {
        //TODO: -Update ad config here
    }
    
    func showAdIfAvailable(controller: UIViewController?, listener: FullScreenAdPresentationStateListener?) throws {
        guard !isShowingAd else {
            throw FullScreenAdLoaderError.adIsBeingShown
        }
        
        // If the ad is not available yet , throw an error
        if !isAdAvailable() {
            throw FullScreenAdLoaderError.adIsNotAvailable
        }
        
        presentationStateListener = listener
        isShowingAd = true
        interstitialAd?.present(fromRootViewController: controller)
    }
}

private extension AdmobInterstitialAdLoader {
    func isAdAvailable() -> Bool {
        // Check if ad exists and can be shown.
        return interstitialAd != nil
    }
    
    func resetState() {
        interstitialAd = nil
        isShowingAd = false
    }
    
    func resetListener() {
        presentationStateListener = nil
    }
}

extension AdmobInterstitialAdLoader: GADFullScreenContentDelegate {
    public func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
        
    }
    
    public func adDidRecordClick(_ ad: GADFullScreenPresentingAd) {
        
    }
    
    public func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        resetState()
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
        resetState()
        presentationStateListener?(.didDismiss)
        resetListener()
    }
}
