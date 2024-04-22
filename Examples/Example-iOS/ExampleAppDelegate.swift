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
class ExampleAppDelegate: ServiceProviderAppDelegate {
    override init() {
        super.init()
    }
    
    nonisolated var rcSettings: RemoteConfigSettings {
        let rc = RemoteConfigSettings()
        rc.fetchTimeout = 5
        return rc
    }
    
    let sampleService = SampleService()
    let firebaseCoreService = FirebaseCoreService(options: FirebaseOptions(contentsOfFile: Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") ?? ""))
    nonisolated lazy var firebaseAnalyticsService = FirebaseAnalyticsService(coreService: firebaseCoreService)
    nonisolated lazy var firebaseRCService = FirebaseRemoteConfigService(
        coreService: firebaseCoreService,
        settings: rcSettings,
        defaultPlist: "rc_defaults",
        realTimeEnabled: true)
    
    
    //overriding parent's method
    override var analyticsPlatforms: [any AnalyticsPlatformProtocol] {
        return [firebaseAnalyticsService]
    }
    
    override nonisolated var configCenter: ConfigCenterProtocol? {
        return firebaseRCService
    }
    
    override var services: [ServiceProtocol] {
        return [sampleService,
                firebaseCoreService,
                firebaseAnalyticsService,
                firebaseRCService]
    }
    
}
