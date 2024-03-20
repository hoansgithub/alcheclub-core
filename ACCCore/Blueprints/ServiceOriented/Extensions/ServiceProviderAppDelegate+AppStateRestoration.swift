//
//  ServiceProviderAppDelegate+AppStateResoration.swift
//  VCLCore
//
//  Created by HoanNL on 15/09/2023.
//
#if os(iOS)
import UIKit

extension ServiceProviderAppDelegate {

//    @available(iOS 6.0, *)
//    open func application(_ application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool {
//        var result = false
//        for service in services {
//            if service.appDelegate?.application?(application, shouldSaveApplicationState: coder) ?? false {
//                result = true
//            }
//        }
//        return result
//    }

//    @available(iOS 6.0, *)
//    open func application(_ application: UIApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool {
//        var result = false
//        for service in services {
//            if service.appDelegate?.application?(application, shouldRestoreApplicationState: coder) ?? false {
//                result = true
//            }
//        }
//        return result
//    }

    @available(iOS 6.0, *)
    open func application(_ application: UIApplication, viewControllerWithRestorationIdentifierPath identifierComponents: [String], coder: NSCoder) -> UIViewController? {
        for service in services {
            if let viewController = service.appDelegate?.application?(application, viewControllerWithRestorationIdentifierPath: identifierComponents, coder: coder) {
                return viewController
            }
        }

        return nil
    }

    @available(iOS 6.0, *)
    open func application(_ application: UIApplication, willEncodeRestorableStateWith coder: NSCoder) {
        for service in services {
            service.appDelegate?.application?(application, willEncodeRestorableStateWith: coder)
        }
    }

    @available(iOS 6.0, *)
    open func application(_ application: UIApplication, didDecodeRestorableStateWith coder: NSCoder) {
        for service in services {
            service.appDelegate?.application?(application, didDecodeRestorableStateWith: coder)
        }
    }
}
#endif
