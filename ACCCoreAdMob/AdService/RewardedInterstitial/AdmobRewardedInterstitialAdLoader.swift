//
//  AdmobRewardedInterstitialAdLoader.swift
//  ACCCoreAdMob
//
//  Created by Hoan Nguyen on 23/5/24.
//

import Foundation
import GoogleMobileAds
import ACCCore

public final class AdmobRewardedInterstitialAdLoader: AdmobFullScreenAdLoader {
    private var rewardedInterstitialAd: GADRewardedInterstitialAd?
    
    internal func loadAd(options: ACCAdOptionsCollection? = nil) async throws {
        if isLoadingAd {
            throw FullScreenAdLoaderError.adIsBeingLoaded
        }
        
        if isAdAvailable() {
            throw FullScreenAdLoaderError.adIsAlreadyLoaded
        }
        
        isLoadingAd = true
        
        do {
            rewardedInterstitialAd = try await GADRewardedInterstitialAd.load(
                withAdUnitID: adUnitID, request: GADRequest())
            
            /*
             [Optional] Validate server-side verification (SSV) callbacks
             
             https://developers.google.com/admob/ios/rewarded#validate-ssv
             */
            if let optionsCollection = options {
                let verificationOptions = GADServerSideVerificationOptions.fromCollection(optionsCollection)
                rewardedInterstitialAd?.serverSideVerificationOptions = verificationOptions
            }
            rewardedInterstitialAd?.fullScreenContentDelegate = self
            isLoadingAd = false
        } catch {
            isLoadingAd = false
            throw FullScreenAdLoaderError.adFailedToLoad(projectedError: error)
        }
        
    }
    
    public override func update(with config: any ConfigObject) {
        //TODO: -Update ad config here
    }
    
    public override func presentAdIfAvailable(controller: UIViewController?, listener: FullScreenAdPresentationStateListener?) throws {
        
        try super.presentAdIfAvailable(controller: controller, listener: listener)
        rewardedInterstitialAd?.present(fromRootViewController: controller, userDidEarnRewardHandler: { [weak self] in
            if (self?.rewardedInterstitialAd?.adReward) != nil {
                listener?(.rewarded)
            } else {
                ACCLogger.print("User failed to get reward", level: .default)
            }
        })
    }
    
}

public extension AdmobRewardedInterstitialAdLoader {
    override func isAdAvailable() -> Bool {
        // Check if ad exists and can be shown.
        return rewardedInterstitialAd != nil
    }
    
    override func resetState() {
        rewardedInterstitialAd = nil
        super.resetState()
    }
}


