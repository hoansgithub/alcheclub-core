//
//  ConfigCenterProtocol.swift
//  ACCCore
//
//  Created by HoanNL on 19/04/2024.
//

import Foundation
import Combine
public protocol ConfigCenterProtocol: Sendable, AnyObject {
    var configPublisher: AnyPublisher<ConfigObject, Never> { get }
}

public protocol ConfigObject {
    subscript<T: Codable>(rcKey: String) -> T? { get }
}
