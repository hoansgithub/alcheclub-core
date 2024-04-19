//
//  AnalyticsEventTrackerProtocol.swift
//  ACCCore
//
//  Created by HoanNL on 17/04/2024.
//

import Foundation
public protocol AnalyticsEventTrackerProtocol: AnyObject {
    var analyticsPlatforms: [AnalyticsPlatformProtocol] { get }
}

public extension AnalyticsEventTrackerProtocol {
    func track(event: AnalyticsEvent) {
        analyticsPlatforms.forEach { platform in
            guard platform.canTrack else { return }
            #if !DEBUG
            platform.track(event: event)
            #else
            ACCLogger.print(event, level: .info)
            #endif
        }
    }
}
