//
//  AnalyticsPlatform.swift
//  ACCCore
//
//  Created by HoanNL on 17/04/2024.
//

import Foundation
public protocol AnalyticsPlatform: Sendable, AnyObject, Identifiable {
    var id: String { get }
    func track(event: AnalyticsEvent)
    var canTrack: Bool { get }
}
