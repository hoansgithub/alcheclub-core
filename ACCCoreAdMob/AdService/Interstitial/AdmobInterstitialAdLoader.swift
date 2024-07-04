//
//  AdmobInterstitialAdLoader.swift
//  ACCCoreAdMob
//
//  Created by HoanNL on 21/05/2024.
//

import ACCCore
import UIKit
import GoogleMobileAds

public final class AdmobInterstitialAdLoader: AdmobFullScreenAdLoader {
    //State
    private var interstitialAd: GADInterstitialAd?
    
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
    
    public override func update(with config: ConfigContainer) {
        //TODO: -Update ad config here
    }
    
    public override func presentAdIfAvailable(controller: UIViewController?, listener: FullScreenAdPresentationStateListener?) throws {
        try super.presentAdIfAvailable(controller: controller, listener: listener)
        interstitialAd?.present(fromRootViewController: controller)
    }
}

public extension AdmobInterstitialAdLoader {
    override func isAdAvailable() -> Bool {
        // Check if ad exists and can be shown.
        return interstitialAd != nil
    }
    
    override func resetState() {
        interstitialAd = nil
        super.resetState()
    }
}

