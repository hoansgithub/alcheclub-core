//
//  AdmobFullScreenAdLoader.swift
//  ACCCoreAdMob
//
//  Created by Hoan Nguyen on 22/5/24.
//

import Foundation
import GoogleMobileAds
import ACCCore
open class AdmobFullScreenAdLoader: NSObject, FullScreenAdLoader {
    //State
    var isLoadingAd = false
    var isShowingAd = false
    //Full screen state
    var presentationStateListener: FullScreenAdPresentationStateListener?
    
    //required properties
    public weak var eventDelegate: TrackableServiceDelegate?
    public private(set) var adUnitIDs: [String] = []
    
    public required init(adUnitIDs: [String]) {
        self.adUnitIDs = adUnitIDs
        super.init()
    }
    
    
    
    
    open dynamic func update(with config: any ConfigContainer) {
        //TODO: -Update ad config here
    }
    
    open dynamic func presentAdIfAvailable(controller: UIViewController?, listener: FullScreenAdPresentationStateListener?) throws {
        guard !isShowingAd else {
            throw FullScreenAdLoaderError.adIsBeingShown
        }
        
        // If the ad is not available yet , throw an error
        if !isAdAvailable() {
            throw FullScreenAdLoaderError.adIsNotAvailable
        }
        
        presentationStateListener = listener
        isShowingAd = true
    }
}

extension AdmobFullScreenAdLoader {
    @objc open dynamic func isAdAvailable() -> Bool {
        return false
    }
    
    @objc open dynamic func resetState() {
        isShowingAd = false
    }
    
    @objc open dynamic func resetListener() {
        presentationStateListener = nil
    }
    
}

extension AdmobFullScreenAdLoader: GADFullScreenContentDelegate {
    open func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
        
    }
    
    open func adDidRecordClick(_ ad: GADFullScreenPresentingAd) {
        
    }
    
    open func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        resetState()
        presentationStateListener?(.failedToPresent(error: error))
        resetListener()
    }
    
    open func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        presentationStateListener?(.willPresent)
    }
    
    open func adWillDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        presentationStateListener?(.willDismiss)
    }
    
    open func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        resetState()
        presentationStateListener?(.didDismiss)
        resetListener()
    }
}


/*
 [Optional] Validate server-side verification (SSV) callbacks
 
 https://developers.google.com/admob/ios/rewarded#validate-ssv
 */
public extension GADServerSideVerificationOptions {
    static let KeyGADServerSideVerificationCustomRewardString = "KeyGADServerSideVerificationCustomRewardString"
    static let KeyGADServerSideVerificationUserIdentifier = "KeyGADServerSideVerificationUserIdentifier"
    static func fromCollection(_ collection: ACCAdOptionsCollection) -> GADServerSideVerificationOptions {
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
