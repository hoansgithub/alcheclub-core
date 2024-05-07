//
//  AppServicesManager+AppInitializing.swift
//
//  ACCCore
//
//  Created by HoanNL on 15/09/2023.
//
#if os(iOS)
import UIKit

extension ServiceProviderAppDelegate {

    @available(iOS 6.0, *)
    open func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        var result = false
        services.compactMap({$0 as? UIApplicationDelegate}).forEach { service in
            if service.application?(application, willFinishLaunchingWithOptions: launchOptions) ?? false {
                result = true
            }
        }
        return result
    }

    @available(iOS 3.0, *)
    open func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        registerServiceEventListener()
        registerConfigCenter(configCenter)
        var result = false
        services.compactMap({$0 as? UIApplicationDelegate}).forEach { service in
            if service.application?(application, didFinishLaunchingWithOptions: launchOptions) ?? false {
                result = true
            }
        }
        return result
    }

    @available(iOS 2.0, *)
    open func applicationDidFinishLaunching(_ application: UIApplication) {
        
        services.compactMap({$0 as? UIApplicationDelegate}).forEach { $0.applicationDidFinishLaunching?(application) }
    }
}
#endif
