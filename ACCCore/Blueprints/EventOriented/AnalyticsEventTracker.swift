//
//  AnalyticsEventTracker.swift
//  ACCCore
//
//  Created by HoanNL on 17/04/2024.
//

import Foundation
public protocol AnalyticsEventTracker: AnyObject {
    var analyticsPlatforms: [any AnalyticsPlatform] { get }
}

public extension AnalyticsEventTracker {
    func track(event: AnalyticsEvent) {
        analyticsPlatforms.forEach { platform in
            guard platform.canTrack else { return }
            
            if !AppEnvironment.shared.isSimulator() {
                platform.track(event: event)
            }
#if DEBUG
            ACCLogger.print("\(platform.id) \(event)", level: .info)
#endif
            
        }
    }
}
