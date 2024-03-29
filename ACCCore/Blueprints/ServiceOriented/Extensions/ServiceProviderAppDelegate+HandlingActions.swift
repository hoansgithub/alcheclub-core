//
//  ServiceProviderAppDelegate+HandlingActions.swift
//  VCLCore
//
//  Created by HoanNL on 15/09/2023.
//
#if os(iOS)
import UIKit

extension ServiceProviderAppDelegate {

    // Called when the user activates your application by selecting a shortcut on the home screen,
    // except when -application:willFinishLaunchingWithOptions: or -application:didFinishLaunchingWithOptions returns NO.
    @available(iOS 9.0, *)
    open func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        apply({ (service, completionHandler) -> Void? in
            service.appDelegate?.application?(application, performActionFor: shortcutItem, completionHandler: completionHandler)
        }, completionHandler: { results in
            // if any service handled the shortcut, return true
            let result = results.reduce(false, { $0 || $1 })
            completionHandler(result)
        })
    }
}
#endif
