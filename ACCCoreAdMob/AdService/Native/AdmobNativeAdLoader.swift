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
    
    @MainActor internal func getNativeAd(for key: String, root: UIViewController?, adReceiver: NativeAdReceiver?) {
        
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
        let starView = starRatingImage?(nativeAd.starRating ?? 0)
        Task { @MainActor in
            if let nativeAdView = template as? GADNativeAdView {
                // Populate the native ad view with the native ad assets.
                // The headline and mediaContent are guaranteed to be present in every native ad.
                (nativeAdView.headlineView as? UILabel)?.text = nativeAd.headline
                nativeAdView.mediaView?.mediaContent = nativeAd.mediaContent
                
                // This app uses a fixed width for the GADMediaView and changes its height to match the aspect
                // ratio of the media it displays.
                if let mediaView = nativeAdView.mediaView, nativeAd.mediaContent.aspectRatio > 0 {
                    let heightConstraint = NSLayoutConstraint(
                        item: mediaView,
                        attribute: .height,
                        relatedBy: .equal,
                        toItem: mediaView,
                        attribute: .width,
                        multiplier: CGFloat(1 / nativeAd.mediaContent.aspectRatio),
                        constant: 0)
                    heightConstraint.isActive = true
                }
                
                // These assets are not guaranteed to be present. Check that they are before
                // showing or hiding them.
                (nativeAdView.bodyView as? UILabel)?.text = nativeAd.body
                nativeAdView.bodyView?.isHidden = nativeAd.body == nil
                
                (nativeAdView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
                nativeAdView.callToActionView?.isHidden = nativeAd.callToAction == nil
                
                (nativeAdView.iconView as? UIImageView)?.image = nativeAd.icon?.image
                nativeAdView.iconView?.isHidden = nativeAd.icon == nil
                
                (nativeAdView.starRatingView as? UIImageView)?.image = starView
                nativeAdView.starRatingView?.isHidden = nativeAd.starRating == nil
                
                (nativeAdView.storeView as? UILabel)?.text = nativeAd.store
                nativeAdView.storeView?.isHidden = nativeAd.store == nil
                
                (nativeAdView.priceView as? UILabel)?.text = nativeAd.price
                nativeAdView.priceView?.isHidden = nativeAd.price == nil
                
                (nativeAdView.advertiserView as? UILabel)?.text = nativeAd.advertiser
                nativeAdView.advertiserView?.isHidden = nativeAd.advertiser == nil
                
                // In order for the SDK to process touch events properly, user interaction should be disabled.
                nativeAdView.callToActionView?.isUserInteractionEnabled = false
                
                // Associate the native ad view with the native ad object. This is
                // required to make the ad clickable.
                // Note: this should always be done after populating the ad views.
                nativeAdView.nativeAd = nativeAd
                adViewReceiver?(nativeAdView)
            }
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
