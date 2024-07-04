//
//  ServiceProvider.swift
//  ACCCore
//
//  Created by HoanNL on 19/03/2024.
//

import Foundation
public protocol ServiceProvider: AnyObject {
    static func getService<S>(_ type: S.Type) -> S?
    static func mapServices<E>(_ transform: (ACCService) -> E?) -> [E]
}
