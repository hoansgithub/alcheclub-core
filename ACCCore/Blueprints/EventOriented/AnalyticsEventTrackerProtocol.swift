//
//  AnalyticsEventTrackerProtocol.swift
//  ACCCore
//
//  Created by HoanNL on 17/04/2024.
//

import Foundation
public protocol AnalyticsEventTrackerProtocol: AnyObject {
    var platforms: [AnalyticsPlatformProtocol] { get }
}

public extension AnalyticsEventTrackerProtocol {
    func track(event: AnalyticsEvent) {
        platforms.forEach { platform in
            platform.track(event: event)
        }
    }
}
