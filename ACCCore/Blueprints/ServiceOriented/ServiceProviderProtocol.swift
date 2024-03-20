//
//  ServiceProviderProtocol.swift
//  ACCCore
//
//  Created by HoanNL on 19/03/2024.
//

import Foundation
public protocol ServiceProviderProtocol {
    var services: [ServiceProtocol] { set get }
    func getService<S>(_ type: S.Type) -> S? where S: ServiceProtocol
}
