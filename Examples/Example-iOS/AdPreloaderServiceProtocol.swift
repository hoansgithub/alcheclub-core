//
//  AdPreloaderServiceProtocol.swift
//  Example-iOS
//
//  Created by HoanNL on 14/05/2024.
//

import ACCCore
import Combine
import UIKit
import ACCCoreAdMob
public protocol AdPreloaderServiceProtocol: ACCService, ServiceStateObservable {
    var firstAppOpenClosedPublisher: AnyPublisher<Bool, Never> { get }
}
