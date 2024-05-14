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
    @MainActor func showAppOpenAdIfAvailable(controller: UIViewController?, listener: FullScreenAdPresentationStateListener?) throws
}
