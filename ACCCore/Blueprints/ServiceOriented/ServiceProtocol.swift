//
//  ServiceProtocol.swift
//  ACCCore
//
//  Created by HoanNL on 19/03/2024.
//

import UIKit
import Combine
public protocol ServiceProtocol: UIApplicationDelegate, UIWindowSceneDelegate {
    var statePublisher: AnyPublisher<ServiceState, Never> { get }
}


