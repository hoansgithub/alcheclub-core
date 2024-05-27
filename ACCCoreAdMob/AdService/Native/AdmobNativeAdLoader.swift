//
//  AdmobNativeAdLoader.swift
//  ACCCoreAdMob
//
//  Created by HoanNL on 27/05/2024.
//

import ACCCore
import GoogleMobileAds

public final class AdmobNativeAdLoader: NSObject, NativeAdLoaderProtocol {
    public weak var eventDelegate: TrackableServiceDelegate?
    public var adUnitID: String = ""
    
    
    //Private properties
    
    public required init(adUnitID: String) {
        self.adUnitID = adUnitID
        super.init()
    }
    
    public func update(with config: any ConfigObject) {
        //TODO: -Update native ad config here
    }
    
    internal func getNativeAd(root: UIViewController?, options: [ACCAdOptionsCollection]?) throws {
        let adLoader = GADAdLoader(adUnitID: adUnitID, rootViewController: root, adTypes: [.native], options: options)
        adLoader.delegate = self
    }
}


extension AdmobNativeAdLoader: GADAdLoaderDelegate {
    public func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: any Error) {
        ACCLogger.print(error.localizedDescription, level: .error)
    }
    
    
}

public extension GADAdLoaderOptions {
    
}
