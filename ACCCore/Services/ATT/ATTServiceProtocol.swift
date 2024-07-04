//
//  ATTServiceProtocol.swift
//  ACCCore
//
//  Created by HoanNL on 02/05/2024.
//

import Foundation
import AppTrackingTransparency
public protocol ATTServiceProtocol: ACCService, ServiceStateObservable {
    func requestTrackingAuthorization() async -> ATTrackingManager.AuthorizationStatus
    var authStatus: ATTrackingManager.AuthorizationStatus { get }
}
