//
//  FirebaseMessagingServiceProtocol.swift
//  ACCCoreFirebase
//
//  Created by HoanNL on 23/04/2024.
//

import Foundation
import ACCCore
import Combine
import UserNotifications
public protocol FirebaseMessagingServiceProtocol:  ServiceProtocol {
    var authStatusPublisher: AnyPublisher<UNAuthorizationStatus, Never> { get }
    func startService() async throws -> UNAuthorizationStatus
}
