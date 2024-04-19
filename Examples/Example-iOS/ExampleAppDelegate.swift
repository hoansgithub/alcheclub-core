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
class ExampleAppDelegate: ServiceProviderAppDelegate {
    override init() {
        super.init()
    }
    let sampleService = SampleService()
    let firebaseCoreService = FirebaseCoreService(options: FirebaseOptions(contentsOfFile: "GoogleService-Info"))
    nonisolated lazy var firebaseAnalyticsService = FirebaseAnalyticsService(coreService: firebaseCoreService)
    
    
    override var analyticsPlatforms: [AnalyticsPlatformProtocol] {
        return [firebaseAnalyticsService]
    }
    
    override var services: [ServiceProtocol] {
        return [sampleService, firebaseCoreService, firebaseAnalyticsService]
    }
    
}
