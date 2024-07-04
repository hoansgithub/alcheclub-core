//
//  ConfigurableObject.swift
//  ACCCore
//
//  Created by HoanNL on 19/04/2024.
//

import Foundation
import Combine
public protocol ConfigurableObject: AnyObject {
    func update(with config: ConfigContainer)
}
