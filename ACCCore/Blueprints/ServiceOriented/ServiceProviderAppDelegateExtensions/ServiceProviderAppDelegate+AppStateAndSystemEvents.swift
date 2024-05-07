//
//  ServiceProviderAppDelegate+AppStateAndSystemEvents.swift
//  ACCCore
//
//  Created by HoanNL on 15/09/2023.
//
#if os(iOS)
import UIKit

extension ServiceProviderAppDelegate {
    
    @available(iOS 2.0, *)
    open func applicationDidBecomeActive(_ application: UIApplication) {
        ACCApp.mapServices({$0 as? UIApplicationDelegate}).forEach { service in
            service.applicationDidBecomeActive?(application)
        }
    }
    
    @available(iOS 2.0, *)
    open func applicationWillResignActive(_ application: UIApplication) {
        ACCApp.mapServices({$0 as? UIApplicationDelegate}).forEach { service in
            service.applicationWillResignActive?(application)
        }
    }
    
    @available(iOS 4.0, *)
    open func applicationDidEnterBackground(_ application: UIApplication) {
        ACCApp.mapServices({$0 as? UIApplicationDelegate}).forEach { service in
            service.applicationDidEnterBackground?(application)
        }
    }
    
    @available(iOS 4.0, *)
    open func applicationWillEnterForeground(_ application: UIApplication) {
        ACCApp.mapServices({$0 as? UIApplicationDelegate}).forEach { service in
            service.applicationWillEnterForeground?(application)
        }
    }
    
    @available(iOS 2.0, *)
    open func applicationWillTerminate(_ application: UIApplication) {
        ACCApp.mapServices({$0 as? UIApplicationDelegate}).forEach { service in
            service.applicationWillTerminate?(application)
        }
    }
    
    @available(iOS 4.0, *)
    open func applicationProtectedDataWillBecomeUnavailable(_ application: UIApplication) {
        ACCApp.mapServices({$0 as? UIApplicationDelegate}).forEach { service in
            service.applicationProtectedDataWillBecomeUnavailable?(application)
        }
    }
    
    @available(iOS 4.0, *)
    open func applicationProtectedDataDidBecomeAvailable(_ application: UIApplication) {
        ACCApp.mapServices({$0 as? UIApplicationDelegate}).forEach { service in
            service.applicationProtectedDataDidBecomeAvailable?(application)
        }
    }
    
    @available(iOS 2.0, *)
    open func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        ACCApp.mapServices({$0 as? UIApplicationDelegate}).forEach { service in
            service.applicationDidReceiveMemoryWarning?(application)
        }
    }
    
    @available(iOS 2.0, *)
    open func applicationSignificantTimeChange(_ application: UIApplication) {
        ACCApp.mapServices({$0 as? UIApplicationDelegate}).forEach { service in
            service.applicationSignificantTimeChange?(application)
        }
    }
}
#endif
