//
//  ServiceProviderAppDelegate+ExtensionTypes.swift
//  ACCCore
//
//  Created by HoanNL on 15/09/2023.
//
#if os(iOS)
import UIKit

extension ServiceProviderAppDelegate {
    
    // Applications may reject specific types of extensions based on the extension point identifier.
    // Constants representing common extension point identifiers are provided further down.
    // If unimplemented, the default behavior is to allow the extension point identifier.
    @available(iOS 8.0, *)
    open func application(_ application: UIApplication, shouldAllowExtensionPointIdentifier extensionPointIdentifier: UIApplication.ExtensionPointIdentifier) -> Bool {
        var result = false
        ACCApp.mapServices({$0 as? UIApplicationDelegate}).forEach { service in
            if service.application?(application, shouldAllowExtensionPointIdentifier: extensionPointIdentifier) ?? true {
                result = true
            }
        }
        return result
    }
}
#endif
