//
//  AdServiceProtocol.swift
//  ACCCoreAdMob
//
//  Created by HoanNL on 07/05/2024.
//

import ACCCore

public protocol AdServiceProtocol: ServiceProtocol {
    var bannerAdLoader: BannerAdLoaderProtocol? { get }
}
