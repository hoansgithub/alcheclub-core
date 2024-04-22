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
    let sampleService = SampleService()
    let firebaseCoreService = FirebaseCoreService(options: FirebaseOptions(contentsOfFile: "GoogleService-Info"))
    nonisolated lazy var firebaseAnalyticsService = FirebaseAnalyticsService(coreService: firebaseCoreService)
    nonisolated lazy var firebaseRCService = FirebaseRemoteConfigService(
        coreService: firebaseCoreService,
        settings: RemoteConfigSettings(),
        defaultPlist: "",
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
