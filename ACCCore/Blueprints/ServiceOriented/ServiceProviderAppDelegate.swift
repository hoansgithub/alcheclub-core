//
//  ServiceProviderAppDelegate.swift
//  ACCCore
//
//  Created by HoanNL on 19/03/2024.
//

import UIKit

open class ServiceProviderAppDelegate: UIResponder, UIApplicationDelegate, UIWindowSceneDelegate, ServiceProviderProtocol {
    open var services: [ServiceProtocol] = []
    
    public func getService<S>(_ type: S.Type) -> S? where S : ServiceProtocol {
        <#code#>
    }
    
    
}


public extension ServiceProviderAppDelegate {
    @discardableResult
    func apply<T, S>(_ work: (ServiceDelegateProtocol, @escaping (T) -> Void) -> S?, completionHandler: @escaping ([T]) -> Void) -> [S] {
        let dispatchGroup = DispatchGroup()
        var results: [T] = []
        var returns: [S] = []

        for service in services {
            dispatchGroup.enter()

            let returned = work(service) { result in
                results.append(result)
                dispatchGroup.leave()
            }

            if let returned = returned {
                returns.append(returned)
            } else {
                dispatchGroup.leave()
            }

            if returned == nil {}
        }

        dispatchGroup.notify(queue: .main) {
            completionHandler(results)
        }
        return returns
    }
}
