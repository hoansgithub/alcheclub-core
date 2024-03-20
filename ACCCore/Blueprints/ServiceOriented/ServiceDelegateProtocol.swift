//
//  ServiceDelegateProtocol.swift
//  ACCCore
//
//  Created by HoanNL on 19/03/2024.
//

import UIKit
public protocol ServiceDelegateProtocol: ServiceProtocol {
    var appDelegate: UIApplicationDelegate? { get }
    var sceneDelegate: UIWindowSceneDelegate? { get }
}
