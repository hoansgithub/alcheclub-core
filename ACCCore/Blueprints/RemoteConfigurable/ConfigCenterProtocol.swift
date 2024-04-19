//
//  ConfigCenterProtocol.swift
//  ACCCore
//
//  Created by HoanNL on 19/04/2024.
//

import Foundation
import Combine
public protocol ConfigCenterProtocol: AnyObject {
    var configPublisher: AnyPublisher<ConfigObject, Never> { get }
}

public protocol ConfigObject {
    subscript<T>(dynamicMember key: String) -> T { get set }
}
