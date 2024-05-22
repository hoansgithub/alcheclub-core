//
//  FullScreenAdLoadeProtocol+GADFullScreenContentDelegate.swift
//  ACCCoreAdMob
//
//  Created by Hoan Nguyen on 22/5/24.
//

import Foundation
import GoogleMobileAds
import ACCCore
public class AdmobFullScreenAdLoader: NSObject, FullScreenAdLoaderProtocol, GADFullScreenContentDelegate {
    //State
    var isLoadingAd = false
    var isShowingAd = false
    //Full screen state
    private var presentationStateListener: FullScreenAdPresentationStateListener?
    
    //required properties
    public weak var eventDelegate: TrackableServiceDelegate?
    public private(set) var adUnitID: String = ""
    
    public required init(adUnitID: String) {
        self.adUnitID = adUnitID
        super.init()
    }
    
    open func loadAd() async throws {
        // Do not load ad if there is an unused ad or one is already loading.
        if isLoadingAd {
            throw FullScreenAdLoaderError.adIsBeingLoaded
        }
        
        if isAdAvailable() {
            throw FullScreenAdLoaderError.adIsAlreadyLoaded
        }
        isLoadingAd = true
        
    }
    
    open func isAdAvailable() -> Bool {
        return false
    }
    
    open func resetState() {
        isShowingAd = false
    }
    
    open func resetListener() {
        presentationStateListener = nil
    }
    
    open func update(with config: any ConfigObject) {
        //TODO: -Update ad config here
    }
    
    open func showAdIfAvailable(controller: UIViewController?, listener: FullScreenAdPresentationStateListener?) throws {
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
