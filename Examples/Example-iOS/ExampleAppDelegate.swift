//
//  ExampleAppDelegate.swift
//  Example-iOS
//
//  Created by HoanNL on 16/04/2024.
//

import Foundation
import ACCCore
import ACCCoreFirebase
import FirebaseCore
import FirebaseRemoteConfig
import ACCCoreAdMob
import UserMessagingPlatform
import WebKit
import ACCCoreStoreKit
class ExampleAppDelegate: ServiceProviderAppDelegate {
    /*
     workaround for handling webview slow initiation at first launch
     https://stackoverflow.com/questions/74301868/wkwebview-ios-slow-on-first-launch
     */
    func woraroundInitialWebViewDelay() {
        let webView = WKWebView()
        webView.loadHTMLString("", baseURL: nil)
    }
    
    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        woraroundInitialWebViewDelay()
        var rcSettings: RemoteConfigSettings {
            let rc = RemoteConfigSettings()
            rc.fetchTimeout = 5
            return rc
        }
        
        
        let firebaseCoreService = FirebaseCoreService(options: FirebaseOptions(contentsOfFile: Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") ?? ""))
        let firebaseAnalyticsService = FirebaseAnalyticsService(coreService: firebaseCoreService)
        let firebaseRCService = FirebaseRemoteConfigService(
            coreService: firebaseCoreService,
            settings: rcSettings,
            defaultPlist: "rc_defaults",
            realTimeEnabled: true)
        let firebaseMessagingService = FirebaseMessagingService(coreService: firebaseCoreService, authOptions: [.alert, .badge, .sound], presentationOptions: [.banner, .list, .sound, .badge])
        
        //ads
        let umpDebugSettings = {
            let debugSettings = UMPDebugSettings()
            debugSettings.geography = UMPDebugGeography.EEA
            debugSettings.testDeviceIdentifiers = ["C42F63AF-6086-4631-910B-B4AB8BB32DC0"]
            return debugSettings
        }()
        let umpService = GoogleUMPService(debugSettings: umpDebugSettings)
        
        let bannerAdLoader = AdMobBannerAdLoader(adUnitIDs: [AdmobIDs.Banner.normal])
        let appOpenAdLoader = AdmobAppOpenAdLoader(adUnitIDs: [AdmobIDs.AppOpen.normal])
        let interstitialAdLoader = AdmobInterstitialAdLoader(adUnitIDs: [AdmobIDs.Inter.normal])
        let rewardedAdLoader = AdmobRewardedAdLoader(adUnitIDs: [AdmobIDs.Reward.normal])
        let rewardedInterstitialAdLoader = AdmobRewardedInterstitialAdLoader(adUnitIDs: [AdmobIDs.RwdInter.normal])
        let nativeAdLoader = AdmobNativeAdLoader(adUnitIDs: [AdmobIDs.Nat.normal])
        let admobService = AdmobService(umpService: umpService,
                                        bannerAdLoader: bannerAdLoader,
                                        appOpenAdLoader: appOpenAdLoader,
                                        interstitialAdLoader: interstitialAdLoader,
                                        rewardedAdLoader: rewardedAdLoader,
                                        rewardedInterstitialAdLoader: rewardedInterstitialAdLoader,
        nativeAdLoader: nativeAdLoader)
        
        let sampleService = SampleService()
        let adPreloaderService = AdPreloaderService(adService: admobService)
        let storeService = StoreService(productIdentifiers: StorePreset.shared.productIdentifiers)
        ACCApp.configure(services: [ATTService.shared,
                                    sampleService,
                                    firebaseCoreService,
                                    firebaseAnalyticsService,
                                    firebaseRCService,
                                    firebaseMessagingService,
                                    umpService,
                                    admobService,
                                    adPreloaderService,
                                    TeslaService.shared,
                                    storeService],
                         analyticsPlatforms: [firebaseAnalyticsService],
                         configCenter: firebaseRCService)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}


struct AdmobIDs {
    struct Banner {
        static let normal = "ca-app-pub-3940256099942544/2435281174"
    }
    struct AppOpen {
        static let normal = "ca-app-pub-3940256099942544/5575463023"
    }
    
    struct Inter {
        static let normal = "ca-app-pub-3940256099942544/4411468910"
    }
    
    struct Reward {
        static let normal = "ca-app-pub-3940256099942544/1712485313"
    }
    
    struct RwdInter {
        static let normal = "ca-app-pub-3940256099942544/6978759866"
    }
    
    struct Nat {
        static let normal = "ca-app-pub-3940256099942544/3986624511"
    }
}
