//
//  AdmobFullScreenAdLoader.swift
//  ACCCoreAdMob
//
//  Created by Hoan Nguyen on 22/5/24.
//

import Foundation
import GoogleMobileAds
import ACCCore
open class AdmobFullScreenAdLoader: NSObject, FullScreenAdLoaderProtocol {
    //State
    var isLoadingAd = false
    var isShowingAd = false
    //Full screen state
    var presentationStateListener: FullScreenAdPresentationStateListener?
    
    //required properties
    public weak var eventDelegate: TrackableServiceDelegate?
    public private(set) var adUnitID: String = ""
    
    public required init(adUnitID: String) {
        self.adUnitID = adUnitID
        super.init()
    }
    
    
    
    
    open dynamic func update(with config: any ConfigObject) {
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
