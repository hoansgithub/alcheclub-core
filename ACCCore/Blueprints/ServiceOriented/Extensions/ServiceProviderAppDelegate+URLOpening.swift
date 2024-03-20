//
//  ServiceProviderAppDelegate+URLOpening.swift
//  VCLCore
//
//  Created by HoanNL on 15/09/2023.
//
#if os(iOS)
import UIKit

extension ServiceProviderAppDelegate {

    @available(iOS 9.0, *)
    open func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        var result = false
        for service in services {
            if service.appDelegate?.application?(app, open: url, options: options) ?? false {
                result = true
            }
        }
        return result
    }
}

#endif
