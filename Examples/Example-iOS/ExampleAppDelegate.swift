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
class ExampleAppDelegate: ServiceProviderAppDelegate {
    
    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
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
        
        let bannerAdLoader = AdMobBannerAdLoader(adUnitID: "ca-app-pub-3940256099942544/2435281174")
        let appOpenAdLoader = AdmobAppOpenAdLoader(adUnitID: "ca-app-pub-3940256099942544/5575463023")
        let interstitialAdLoader = AdmobInterstitialAdLoader(adUnitID: "ca-app-pub-3940256099942544/4411468910")
        let rewardedAdLoader = AdmobRewardedAdLoader(adUnitID: "ca-app-pub-3940256099942544/1712485313")
        let rewardedInterstitialAdLoader = AdmobRewardedInterstitialAdLoader(adUnitID: "ca-app-pub-3940256099942544/6978759866")
        let admobService = AdmobService(umpService: umpService,
                                        bannerAdLoader: bannerAdLoader,
                                        appOpenAdLoader: appOpenAdLoader,
                                        interstitialAdLoader: interstitialAdLoader,
                                        rewardedAdLoader: rewardedAdLoader,
                                        rewaredInterstitialAdLoader: rewardedInterstitialAdLoader)
        
        let sampleService = SampleService()
        let adPreloaderService = AdPreloaderService(adService: admobService)
        ACCApp.configure(services: [ATTService.shared,
                                    sampleService,
                                    firebaseCoreService,
                                    firebaseAnalyticsService,
                                    firebaseRCService,
                                    firebaseMessagingService,
                                    umpService,
                                    admobService,
                                    adPreloaderService],
                         analyticsPlatforms: [firebaseAnalyticsService],
                         configCenter: firebaseRCService)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
