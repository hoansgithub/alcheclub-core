//
//  AdmobRewardedAdLoader.swift
//  ACCCoreAdMob
//
//  Created by Hoan Nguyen on 22/5/24.
//

import GoogleMobileAds
import UIKit
import ACCCore

public final class AdmobRewardedAdLoader: AdmobFullScreenAdLoader {
    //State
    private var rewardedAd: GADRewardedAd?

    internal func loadAd(unitID: String, options: ACCAdOptionsCollection? = nil) async throws {
        if isLoadingAd {
            throw FullScreenAdLoaderError.adIsBeingLoaded
        }
        
        if isAdAvailable() {
            throw FullScreenAdLoaderError.adIsAlreadyLoaded
        }
        
        guard let adUnitID = adUnitIDs.first(where: {$0 == unitID}) else {
            throw FullScreenAdLoaderError.adUnitNotFound
        }
        
        isLoadingAd = true
        
        do {
            rewardedAd = try await GADRewardedAd.load(
                withAdUnitID: adUnitID, request: GADRequest())
            /*
             [Optional] Validate server-side verification (SSV) callbacks
             
             https://developers.google.com/admob/ios/rewarded#validate-ssv
             */
            if let optionsCollection = options {
                let verificationOptions = GADServerSideVerificationOptions.fromCollection(optionsCollection)
                rewardedAd?.serverSideVerificationOptions = verificationOptions
            }
            rewardedAd?.fullScreenContentDelegate = self
            isLoadingAd = false
        } catch {
            isLoadingAd = false
            throw FullScreenAdLoaderError.adFailedToLoad(projectedError: error)
        }
        
    }
    
    public override func update(with config: any ConfigContainer) {
        //TODO: -Update ad config here
    }
    
    public override func presentAdIfAvailable(controller: UIViewController?, listener: FullScreenAdPresentationStateListener?) throws {
        
        try super.presentAdIfAvailable(controller: controller, listener: listener)
        rewardedAd?.present(fromRootViewController: controller, userDidEarnRewardHandler: { [weak self] in
            if (self?.rewardedAd?.adReward) != nil {
                listener?(.rewarded)
            } else {
                ACCLogger.print("User failed to get reward", level: .default)
            }
        })
    }
}

public extension AdmobRewardedAdLoader {
    override func isAdAvailable() -> Bool {
        // Check if ad exists and can be shown.
        return rewardedAd != nil
    }
    
    override func resetState() {
        rewardedAd = nil
        super.resetState()
    }
}


