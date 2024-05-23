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

    internal func loadAd(options: AdVerificationOptionsCollection? = nil) async throws {
        if isLoadingAd {
            throw FullScreenAdLoaderError.adIsBeingLoaded
        }
        
        if isAdAvailable() {
            throw FullScreenAdLoaderError.adIsAlreadyLoaded
        }
        
        isLoadingAd = true
        
        do {
            rewardedAd = try await GADRewardedAd.load(
                withAdUnitID: adUnitID, request: GADRequest())
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
    
    public override func update(with config: any ConfigObject) {
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

extension GADServerSideVerificationOptions {
    static let KeyGADServerSideVerificationCustomRewardString = "KeyGADServerSideVerificationCustomRewardString"
    static let KeyGADServerSideVerificationUserIdentifier = "KeyGADServerSideVerificationUserIdentifier"
    static func fromCollection(_ collection: AdVerificationOptionsCollection) -> GADServerSideVerificationOptions {
        let options = GADServerSideVerificationOptions()
        let customRewardString = collection[KeyGADServerSideVerificationCustomRewardString]
        let userIdentifier = collection[KeyGADServerSideVerificationUserIdentifier]
        if !customRewardString.isEmpty {
            options.customRewardString = customRewardString
        }
        if !userIdentifier.isEmpty {
            options.userIdentifier = userIdentifier
        }
        return options
    }
}
