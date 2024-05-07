//
//  AnalyticsEventTrackerProtocol.swift
//  ACCCore
//
//  Created by HoanNL on 17/04/2024.
//

import Foundation
public protocol AnalyticsEventTrackerProtocol: AnyObject {
    var analyticsPlatforms: [any AnalyticsPlatformProtocol] { get }
}

public extension AnalyticsEventTrackerProtocol {
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
