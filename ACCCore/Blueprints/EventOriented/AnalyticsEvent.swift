//
//  AnalyticsEvent.swift
//  ACCCore
//
//  Created by HoanNL on 17/04/2024.
//

import Foundation
public struct AnalyticsEvent {
    public var name: String
    public private(set) var params: [String: Any]?
    
    public init(_ name: String, params: [String: Any]? = nil) {
        self.name = name
        self.params = params
    }
}
