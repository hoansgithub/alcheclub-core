//
//  AdServiceProtocol.swift
//  ACCCoreAdMob
//
//  Created by HoanNL on 07/05/2024.
//

import ACCCore
import UIKit
public protocol AdServiceProtocol: ServiceProtocol, ServiceStateObservable {
    //Banner
    @MainActor func getBannerAd(for key: String, size: ACCAdSize, root: UIViewController?) async throws -> UIView
    func removeBannerAd(for key: String) -> Bool
    
    //App Open
    @MainActor func loadAppOpenAd() async throws
    @MainActor func presentAppOpenAdIfAvailable(controller: UIViewController?, listener: FullScreenAdPresentationStateListener?) throws
    
    //Interstitial
    @MainActor func loadInterstitialAd() async throws
    @MainActor func presentInterstitialAdIfAvailable(controller: UIViewController?, listener: FullScreenAdPresentationStateListener?) throws
    
    //Rewarded
    @MainActor func loadRewardedAd(options: ACCAdOptionsCollection?) async throws
    @MainActor func presentRewardedAdIfAvailable(controller: UIViewController?, listener: FullScreenAdPresentationStateListener?) throws
    
    //RewardedInterstitial
    @MainActor func loadRewardedInterstitialAd(options: ACCAdOptionsCollection?) async throws
    @MainActor func presentRewardedInterstitialAdIfAvailable(controller: UIViewController?, listener: FullScreenAdPresentationStateListener?) throws
    
    //Native
    @MainActor func getNativeAds(for key: String, root: UIViewController?, receiver: NativeAdReceiver?)
    func removeNativeAds(for key: String) -> Bool
}
