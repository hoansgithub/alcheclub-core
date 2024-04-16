//
//  ServiceProviderAppDelegate+SceneStateHandling.swift
//  VCLCore
//
//  Created by HoanNL on 15/09/2023.
//

import CloudKit
#if os(iOS)
import UIKit
extension ServiceProviderAppDelegate {
    
    // Called when the UIKit is about to create & vend a new UIScene instance to the application.
    // The application delegate may modify the provided UISceneConfiguration within this method.
    // If the UISceneConfiguration instance returned from this method does not have a systemType which matches the connectingSession's, UIKit will assert
    open func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let sceneConfig = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
            sceneConfig.delegateClass = Self.self
            return sceneConfig
    }

    open func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        services.forEach {
            $0.application?(application, didDiscardSceneSessions: sceneSessions)
        }
    }
    
    // MARK: UIWindowSceneDelegate conformation
    
    // Called when the coordinate space, interface orientation, or trait collection of a UIWindowScene changes
    // Always called when a UIWindowScene moves between screens
    open func windowScene(_ windowScene: UIWindowScene, didUpdate previousCoordinateSpace: UICoordinateSpace, interfaceOrientation previousInterfaceOrientation: UIInterfaceOrientation, traitCollection previousTraitCollection: UITraitCollection) {
        services.forEach {
            $0.windowScene?(windowScene, didUpdate: previousCoordinateSpace, interfaceOrientation: previousInterfaceOrientation, traitCollection: previousTraitCollection)
        }
    }
    
    // Called when the user activates your application by selecting a shortcut on the home screen,
    // and the window scene is already connected.
    open func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        apply({ (service, completionHandler) -> Void? in
            service.windowScene?(windowScene, performActionFor: shortcutItem, completionHandler: completionHandler)
        }, completionHandler: { results in
            // if any service handled the shortcut, return true
            let result = results.reduce(false, { $0 || $1 })
            completionHandler(result)
        })
    }
    
    // Called after the user indicates they want to accept a CloudKit sharing invitation in your application
    // and the window scene is already connected.
    // You should use the CKShareMetadata object's shareURL and containerIdentifier to schedule a CKAcceptSharesOperation, then start using
    // the resulting CKShare and its associated record(s), which will appear in the CKContainer's shared database in a zone matching that of the record's owner.
    open func windowScene(_ windowScene: UIWindowScene, userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata) {
        
        services.forEach {
            $0.windowScene?(windowScene, userDidAcceptCloudKitShareWith: cloudKitShareMetadata)
        }
    }
    
    // MARK: UISceneDelegate conformation
    
    open func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        services.forEach {
            $0.scene?(scene, willConnectTo: session, options: connectionOptions)
        }
    }
    
    open func sceneDidDisconnect(_ scene: UIScene) {
        services.forEach {
            $0.sceneDidDisconnect?(scene)
        }
    }
    
    open func sceneDidBecomeActive(_ scene: UIScene) {
        services.forEach {
            $0.sceneDidBecomeActive?(scene)
        }
    }
    
    open func sceneWillResignActive(_ scene: UIScene) {
        services.forEach {
            $0.sceneWillResignActive?(scene)
        }
    }
    
    open func sceneWillEnterForeground(_ scene: UIScene) {
        services.forEach {
            $0.sceneWillEnterForeground?(scene)
        }
    }
    
    open func sceneDidEnterBackground(_ scene: UIScene) {
        services.forEach {
            $0.sceneDidEnterBackground?(scene)
        }
    }
    
    open func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        services.forEach {
            $0.scene?(scene, openURLContexts: URLContexts)
        }
    }
    
    open func scene(_ scene: UIScene, restoreInteractionStateWith stateRestorationActivity: NSUserActivity) {
        services.forEach {
            $0.scene?(scene, restoreInteractionStateWith: stateRestorationActivity)
        }
    }
    
    open func scene(_ scene: UIScene, willContinueUserActivityWithType userActivityType: String) {
        services.forEach {
            $0.scene?(scene, willContinueUserActivityWithType: userActivityType)
        }
    }
    
    open func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        services.forEach {
            $0.scene?(scene, continue: userActivity)
        }
    }
    
    open func scene(_ scene: UIScene, didFailToContinueUserActivityWithType userActivityType: String, error: Error) {
        services.forEach {
            $0.scene?(scene, didFailToContinueUserActivityWithType: userActivityType, error: error)
        }
    }
    
    open func scene(_ scene: UIScene, didUpdate userActivity: NSUserActivity) {
        services.forEach {
            $0.scene?(scene, didUpdate: userActivity)
        }
    }
}
#endif
