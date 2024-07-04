//
//  AdLoader.swift
//  ACCCoreAdMob
//
//  Created by HoanNL on 07/05/2024.
//

import ACCCore
import UIKit


public protocol AdLoader: ConfigurableObject, TrackableService {
    var adUnitID: String { get }
}

//Banner
public protocol BannerAdLoader: AdLoader {

}

//Native
public protocol NativeAdLoader: AdLoader {
    
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

public protocol FullScreenAdLoader: AdLoader {
    @MainActor func presentAdIfAvailable(controller: UIViewController?, listener: FullScreenAdPresentationStateListener?) throws
}

