//
//  ConfigCenterProtocol.swift
//  ACCCore
//
//  Created by HoanNL on 19/04/2024.
//

import Foundation
import Combine
public protocol ConfigCenterProtocol: AnyObject {
    var configPublisher: AnyPublisher<RemoteConfigObject?, Never> { get }
}

public protocol RemoteConfigObject {
    subscript<T: Codable>(rcKey: String) -> T? { get }
}
