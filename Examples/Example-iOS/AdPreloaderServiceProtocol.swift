//
//  AdPreloaderServiceProtocol.swift
//  Example-iOS
//
//  Created by HoanNL on 14/05/2024.
//

import ACCCore
import Combine
public protocol AdPreloaderServiceProtocol: ServiceProtocol {
    var appOpenClosedPublisher: AnyPublisher<Bool, Never> { get }
}
