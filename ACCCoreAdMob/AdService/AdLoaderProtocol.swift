//
//  AdLoaderProtocol.swift
//  ACCCoreAdMob
//
//  Created by HoanNL on 07/05/2024.
//

import ACCCore
import UIKit


public protocol AdLoaderProtocol: ConfigurableProtocol, TrackableServiceProtocol {
    var adUnitID: String { get }
}

//Banner
public protocol BannerAdLoaderProtocol: AdLoaderProtocol {

}


//FullScreen
public enum FullScreenAdPresentationState {
    case failedToPresent(error: Error)
    case willPresent
    case willDismiss
    case didDismiss
    case rewarded
}

public enum FullScreenAdLoaderError: Error {
    case adIsAlreadyLoaded
    case adIsBeingLoaded
    case adIsBeingShown
    case adIsNotAvailable
    case adFailedToLoad(projectedError: Error)
}

public typealias FullScreenAdPresentationStateListener = (_ state: FullScreenAdPresentationState) -> ()

public protocol FullScreenAdLoaderProtocol: AdLoaderProtocol {
    @MainActor func presentAdIfAvailable(controller: UIViewController?, listener: FullScreenAdPresentationStateListener?) throws
}

///AppOpen
public protocol AppOpenAdLoaderProtocol: FullScreenAdLoaderProtocol {
    
}

///Interstitial
public protocol InterstitialAdLoaderProtocol: FullScreenAdLoaderProtocol {

}

//Rewarded
public protocol RewardedAdLoaderProtocol: FullScreenAdLoaderProtocol {
    
}
