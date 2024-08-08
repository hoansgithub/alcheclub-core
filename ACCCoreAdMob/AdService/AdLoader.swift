//
//  AdLoader.swift
//  ACCCoreAdMob
//
//  Created by HoanNL on 07/05/2024.
//

import ACCCore
import UIKit


public protocol AdLoader: ConfigurableObject, TrackableService {
    var adUnitIDs: [String] { get }
}

//Banner
public protocol BannerAdLoader: AdLoader {

}

//Native
public protocol NativeAdLoader: AdLoader {
    
}


//FullScreen
public enum FullScreenAdPresentationState: Sendable {
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
    case adUnitNotFound
}

public typealias FullScreenAdPresentationStateListener = @Sendable (_ state: FullScreenAdPresentationState) -> ()

public protocol FullScreenAdLoader: AdLoader {
    @MainActor func presentAdIfAvailable(controller: UIViewController?, listener: FullScreenAdPresentationStateListener?) throws
}

