//
//  ServiceProviderAppDelegate+AppStateResoration.swift
//  ACCCore
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
        let delegates = ACCApp.mapServices({$0 as? UIApplicationDelegate})
        for service in delegates {
            if let viewController = service.application?(application, viewControllerWithRestorationIdentifierPath: identifierComponents, coder: coder) {
                return viewController
            }
        }
        
        return nil
    }
    
    @available(iOS 6.0, *)
    open func application(_ application: UIApplication, willEncodeRestorableStateWith coder: NSCoder) {
        ACCApp.mapServices({$0 as? UIApplicationDelegate}).forEach { service in
            service.application?(application, willEncodeRestorableStateWith: coder)
        }
    }
    
    @available(iOS 6.0, *)
    open func application(_ application: UIApplication, didDecodeRestorableStateWith coder: NSCoder) {
        ACCApp.mapServices({$0 as? UIApplicationDelegate}).forEach { service in
            service.application?(application, didDecodeRestorableStateWith: coder)
        }
    }
}
#endif
