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
        
        let sampleService = SampleService()
        let firebaseCoreService = FirebaseCoreService(options: FirebaseOptions(contentsOfFile: Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") ?? ""))
        lazy var firebaseAnalyticsService = FirebaseAnalyticsService(coreService: firebaseCoreService)
        lazy var firebaseRCService = FirebaseRemoteConfigService(
            coreService: firebaseCoreService,
            settings: rcSettings,
            defaultPlist: "rc_defaults",
            realTimeEnabled: true)
        lazy var firebaseMessagingService = FirebaseMessagingService(coreService: firebaseCoreService, authOptions: [.alert, .badge, .sound], presentationOptions: [.banner, .list, .sound, .badge])
        
        //ads
        lazy var umpDebugSettings = {
            let debugSettings = UMPDebugSettings()
            debugSettings.geography = UMPDebugGeography.EEA
            debugSettings.testDeviceIdentifiers = ["C42F63AF-6086-4631-910B-B4AB8BB32DC0"]
            return debugSettings
        }()
        lazy var umpService = GoogleUMPService(debugSettings: umpDebugSettings)
        ACCApp.configure(services: [ATTService.shared,
                                    sampleService,
                                    firebaseCoreService,
                                    firebaseAnalyticsService,
                                    firebaseRCService,
                                    firebaseMessagingService,
                                    umpService], analyticsPlatforms: [firebaseAnalyticsService],
                         configCenter: firebaseRCService)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
