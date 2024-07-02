//
//  FirebaseCoreServiceProtocol.swift
//  ACCCoreFirebase
//
//  Created by HoanNL on 17/04/2024.
//

import Foundation
import ACCCore
import FirebaseCore
public protocol FirebaseCoreServiceProtocol: ServiceProtocol, ServiceStateObservable {
    init(options: FirebaseOptions?)
}
