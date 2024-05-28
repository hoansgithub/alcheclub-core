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
    
    internal func getNativeAd(for key: String, root: UIViewController?, adReceiver: NativeAdReceiver?) {

        //TODO: - ad options mapper
        let adLoader = GADAdLoader(adUnitID: adUnitID, rootViewController: root, adTypes: [.native], options: nil)
        adReceiver?.adLoader = self
        adLoader.delegate = adReceiver
    }
}


extension NativeAdReceiver: GADNativeAdLoaderDelegate {
    public func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: any Error) {
        ACCLogger.print(error.localizedDescription, level: .error)
        errorHandler?(error)
    }
    
    public func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        nativeAd.delegate = (adLoader as? any GADNativeAdDelegate)
        let template = templateGetter?()
        if let template = template as? GADNativeAdView {
            
        }
    }
}

extension AdMobBannerAdLoader: GADNativeAdDelegate {
    public func nativeAdDidRecordImpression(_ nativeAd: GADNativeAd) {
        //TODO: -Track related events
    }
    
    public func nativeAdDidRecordClick(_ nativeAd: GADNativeAd) {
        //TODO: -Track related events
    }
    
    public func nativeAdDidRecordSwipeGestureClick(_ nativeAd: GADNativeAd) {
        //TODO: -Track related events
    }
    
    public func nativeAdWillPresentScreen(_ nativeAd: GADNativeAd) {
        //TODO: -Track related events
    }
    
    public func nativeAdWillDismissScreen(_ nativeAd: GADNativeAd) {
        //TODO: -Track related events
    }
    
    public func nativeAdDidDismissScreen(_ nativeAd: GADNativeAd) {
        //TODO: -Track related events
    }
    
    public func nativeAdIsMuted(_ nativeAd: GADNativeAd) {
        //TODO: -Track related events
    }
}
