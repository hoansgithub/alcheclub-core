//
//  AnalyticsPlatformProtocol.swift
//  ACCCore
//
//  Created by HoanNL on 17/04/2024.
//

import Foundation
public protocol AnalyticsPlatformProtocol: AnyObject {
    func track(event: AnalyticsEvent)
}
