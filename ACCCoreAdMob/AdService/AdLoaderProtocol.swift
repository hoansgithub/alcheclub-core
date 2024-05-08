//
//  AdLoaderProtocol.swift
//  ACCCoreAdMob
//
//  Created by HoanNL on 07/05/2024.
//

import ACCCore
import UIKit
public protocol AdPreloadable: AnyObject {
    func preload()
}

public protocol AdLoaderProtocol: ConfigurableProtocol {
    var adUnitID: String { get set }
}

public protocol BannerAdLoaderProtocol: AdLoaderProtocol, TrackableServiceProtocol {

}
