//
//  GADAdSize+ACCAdSize.swift
//  ACCCoreAdMob
//
//  Created by HoanNL on 08/05/2024.
//

import Foundation
import GoogleMobileAds

public extension GADAdSize {
    static func from(size: ACCAdSize) -> Self {
        switch size {
        case .currentAnchoredAdaptiveBanner(let width):
            return GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(width)
        case .currentInlineAdaptiveBanner(let width):
            return GADCurrentOrientationInlineAdaptiveBannerAdSizeWithWidth(width)
        case .portraitInlineAdaptiveBanner(let width):
            return GADPortraitInlineAdaptiveBannerAdSizeWithWidth(width)
        case .landscapeInlineAdaptiveBanner(let width):
            return GADLandscapeInlineAdaptiveBannerAdSizeWithWidth(width)
        case .inlineAdaptive(let width, let maxHeight):
            return GADInlineAdaptiveBannerAdSizeWithWidthAndMaxHeight(width, maxHeight)
        }
    }
}
