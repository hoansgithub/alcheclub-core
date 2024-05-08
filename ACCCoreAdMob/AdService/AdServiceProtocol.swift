//
//  AdServiceProtocol.swift
//  ACCCoreAdMob
//
//  Created by HoanNL on 07/05/2024.
//

import ACCCore
import UIKit
public protocol AdServiceProtocol: ServiceProtocol {
    func getBanner(for key: String, size: ACCAdSize, root: UIViewController?) async throws -> UIView
}
