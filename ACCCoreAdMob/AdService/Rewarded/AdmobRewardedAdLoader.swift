//
//  AdmobRewardedAdLoader.swift
//  ACCCoreAdMob
//
//  Created by Hoan Nguyen on 22/5/24.
//

import GoogleMobileAds
import UIKit
import ACCCore

public final class AdmobRewardedAdLoader: NSObject, RewardedAdLoaderProtocol {
    //State
    private var rewardedAd: GADRewardedAd?
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
    
    internal func loadAd(optionsCollection: AdVerificationOptionsCollection? = nil) async throws {
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
            if let optionsCollection = optionsCollection {
                let verificationOptions = GADServerSideVerificationOptions.fromCollection(optionsCollection)
                rewardedAd?.serverSideVerificationOptions = verificationOptions
            }
            rewardedAd?.fullScreenContentDelegate = self
            
        } catch {
            isLoadingAd = false
            throw FullScreenAdLoaderError.adFailedToLoad(projectedError: error)
        }
        
    }
}

public extension AdmobRewardedAdLoader {
    func update(with config: any ConfigObject) {
        //TODO: -Update ad config here
    }
    
    func showAdIfAvailable(controller: UIViewController?, listener: FullScreenAdPresentationStateListener?) throws {
        
    }
}

private extension AdmobRewardedAdLoader {
    func isAdAvailable() -> Bool {
        // Check if ad exists and can be shown.
        return rewardedAd != nil
    }
    
    func resetState() {
        rewardedAd = nil
        isShowingAd = false
    }
    
    func resetListener() {
        presentationStateListener = nil
    }
}

extension AdmobRewardedAdLoader: GADFullScreenContentDelegate {
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
