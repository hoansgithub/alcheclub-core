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
        for service in services {
            service.applicationShouldRequestHealthAuthorization?(application)
        }
    }
}
#endif
