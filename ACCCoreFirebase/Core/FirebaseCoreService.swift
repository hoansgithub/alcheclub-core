//
//  FirebaseCoreService.swift
//  ACCCoreFirebase
//
//  Created by HoanNL on 17/04/2024.
//

import Foundation
import ACCCore
import Combine
import UIKit
import FirebaseCore
public final class FirebaseCoreService: NSObject, @unchecked Sendable, FirebaseCoreServiceProtocol {
    private let stateSubject = CurrentValueSubject<ServiceState, Never>(.idle)
    public let statePublisher: AnyPublisher<ServiceState, Never>
    
    private var options: FirebaseOptions?
    required public init(options: FirebaseOptions?) {
        self.options = options
        self.statePublisher = stateSubject.removeDuplicates().eraseToAnyPublisher()
        super.init()
    }
    
}

extension FirebaseCoreService: UIApplicationDelegate {
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        if let options = options {
            FirebaseApp.configure(options: options)
        } else {
            FirebaseApp.configure()
        }
        
        if FirebaseApp.app() != nil {
            stateSubject.send(.ready)
        }
        return true
    }
}
