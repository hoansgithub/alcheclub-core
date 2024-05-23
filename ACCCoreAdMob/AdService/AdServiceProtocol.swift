//
//  AdServiceProtocol.swift
//  ACCCoreAdMob
//
//  Created by HoanNL on 07/05/2024.
//

import ACCCore
import UIKit
public protocol AdServiceProtocol: ServiceProtocol {
    //Banner
    func getBannerAd(for key: String, size: ACCAdSize, root: UIViewController?) async throws -> UIView
    func removeBannerAd(for key: String) -> Bool
    
    //App Open
    func loadAppOpenAd() async throws
    @MainActor func presentAppOpenAdIfAvailable(controller: UIViewController?, listener: FullScreenAdPresentationStateListener?) throws
    
    //Interstitial
    func loadInterstitialAd() async throws
    @MainActor func presentInterstitialAdIfAvailable(controller: UIViewController?, listener: FullScreenAdPresentationStateListener?) throws
    
    //Rewarded
    func loadRewaredAd(options: AdVerificationOptionsCollection?) async throws
    @MainActor func presentRewardedAdIfAvailable(controller: UIViewController?, listener: FullScreenAdPresentationStateListener?) throws
    
    //RewardedInterstitial
    func loadRewaredInterstitialAd(options: AdVerificationOptionsCollection?) async throws
    
    @MainActor func presentRewaredInterstitialAdIfAvailable(controller: UIViewController?, listener: FullScreenAdPresentationStateListener?) throws
}
