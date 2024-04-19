//
//  ServiceProviderAppDelegate+URLOpening.swift
//  ACCCore
//
//  Created by HoanNL on 15/09/2023.
//
#if os(iOS)
import UIKit

extension ServiceProviderAppDelegate {

    @available(iOS 9.0, *)
    open func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        var result = false
        services.compactMap({$0 as? UIApplicationDelegate}).forEach { service in
            if service.application?(app, open: url, options: options) ?? false {
                result = true
            }
        }
        return result
    }
}

#endif
