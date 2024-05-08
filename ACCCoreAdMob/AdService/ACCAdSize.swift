//
//  ACCAdSize.swift
//  ACCCoreAdMob
//
//  Created by HoanNL on 08/05/2024.
//

import Foundation
public enum ACCAdSize: Sendable {
    case currentInlineAdaptiveBanner(width: CGFloat)
    case portraitInlineAdaptiveBanner(width: CGFloat)
    case landscapeInlineAdaptiveBanner(width: CGFloat)
    case inlineAdaptive(width: CGFloat, maxHeight: CGFloat)
}
