//
//  ServiceProviderAppDelegate+AppStateAndSystemEvents.swift
//  VCLCore
//
//  Created by HoanNL on 15/09/2023.
//
#if os(iOS)
import UIKit

extension ServiceProviderAppDelegate {

    @available(iOS 2.0, *)
    open func applicationDidBecomeActive(_ application: UIApplication) {
        for service in services {
            service.appDelegate?.applicationDidBecomeActive?(application)
        }
    }

    @available(iOS 2.0, *)
    open func applicationWillResignActive(_ application: UIApplication) {
        for service in services {
            service.appDelegate?.applicationWillResignActive?(application)
        }
    }

    @available(iOS 4.0, *)
    open func applicationDidEnterBackground(_ application: UIApplication) {
        for service in services {
            service.appDelegate?.applicationDidEnterBackground?(application)
        }
    }

    @available(iOS 4.0, *)
    open func applicationWillEnterForeground(_ application: UIApplication) {
        for service in services {
            service.appDelegate?.applicationWillEnterForeground?(application)
        }
    }

    @available(iOS 2.0, *)
    open func applicationWillTerminate(_ application: UIApplication) {
        for service in services {
            service.appDelegate?.applicationWillTerminate?(application)
        }
    }

    @available(iOS 4.0, *)
    open func applicationProtectedDataWillBecomeUnavailable(_ application: UIApplication) {
        for service in services {
            service.appDelegate?.applicationProtectedDataWillBecomeUnavailable?(application)
        }
    }

    @available(iOS 4.0, *)
    open func applicationProtectedDataDidBecomeAvailable(_ application: UIApplication) {
        for service in services {
            service.appDelegate?.applicationProtectedDataDidBecomeAvailable?(application)
        }
    }

    @available(iOS 2.0, *)
    open func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        for service in services {
            service.appDelegate?.applicationDidReceiveMemoryWarning?(application)
        }
    }

    @available(iOS 2.0, *)
    open func applicationSignificantTimeChange(_ application: UIApplication) {
        for service in services {
            service.appDelegate?.applicationSignificantTimeChange?(application)
        }
    }
}
#endif
