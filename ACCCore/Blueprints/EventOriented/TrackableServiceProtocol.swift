//
//  TrackableServiceProtocol.swift
//  ACCCore
//
//  Created by HoanNL on 07/05/2024.
//

import Foundation
public protocol TrackableServiceDelegate: AnyObject {
    func trackableService(_ service: any TrackableServiceProtocol, didSend event: AnalyticsEvent)
}

public protocol TrackableServiceProtocol where Self: AnyObject {
    var eventDelegate: TrackableServiceDelegate? { get set }
}

public extension TrackableServiceProtocol {
    func track(event: AnalyticsEvent) {
        eventDelegate?.trackableService(self, didSend: event)
    }
}

