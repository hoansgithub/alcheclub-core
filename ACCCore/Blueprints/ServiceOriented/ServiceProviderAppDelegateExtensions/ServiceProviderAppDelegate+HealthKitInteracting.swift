//
//  ServiceProviderAppDelegate+HealthKitInteracting.swift
//  ACCCore
//
//  Created by HoanNL on 15/09/2023.
//
#if os(iOS)
import UIKit

extension ServiceProviderAppDelegate {
    
    @available(iOS 9.0, *)
    open func applicationShouldRequestHealthAuthorization(_ application: UIApplication) {
        ACCApp.mapServices({$0 as? UIApplicationDelegate}).forEach { service in
            service.applicationShouldRequestHealthAuthorization?(application)
        }
    }
}
#endif
