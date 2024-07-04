//
//  ConfigCenter.swift
//  ACCCore
//
//  Created by HoanNL on 19/04/2024.
//

import Foundation
import Combine
public protocol ConfigCenter: Sendable, AnyObject {
    var publisher: AnyPublisher<ConfigContainer, Never> { get }
}

public protocol ConfigContainer {
    subscript<T: Codable>(rcKey: String) -> T? { get }
}
