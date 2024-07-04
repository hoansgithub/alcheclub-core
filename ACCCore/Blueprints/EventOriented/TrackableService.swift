//
//  TrackableService.swift
//  ACCCore
//
//  Created by HoanNL on 07/05/2024.
//

import Foundation
public protocol TrackableServiceDelegate: AnyObject {
    func trackableService(_ service: any TrackableService, didSend event: AnalyticsEvent)
}

public protocol TrackableService where Self: AnyObject {
    var eventDelegate: TrackableServiceDelegate? { get set }
}

public extension TrackableService {
    func track(event: AnalyticsEvent) {
        eventDelegate?.trackableService(self, didSend: event)
    }
}

