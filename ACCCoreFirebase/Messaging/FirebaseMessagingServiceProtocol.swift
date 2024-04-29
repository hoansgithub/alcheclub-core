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
import UIKit
public protocol FirebaseMessagingServiceProtocol:  ServiceProtocol {
    var authStatusPublisher: AnyPublisher<UNAuthorizationStatus, Never> { get }
    var tokenPublisher: AnyPublisher<String, Never> { get }
    func registerForRemoteNotifications() async throws -> Bool
    func getPermissionStatus() async -> UNAuthorizationStatus
}
