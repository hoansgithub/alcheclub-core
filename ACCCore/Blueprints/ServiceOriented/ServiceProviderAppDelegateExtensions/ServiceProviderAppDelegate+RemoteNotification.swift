//
//  ServiceProviderAppDelegate+RemoteNotification.swift
//
//  ACCCore
//
//  Created by HoanNL on 15/09/2023.
//

#if os(iOS)
import UIKit

extension ServiceProviderAppDelegate {
    
    // This callback will be made upon calling -[UIApplication registerUserNotificationSettings:]. The settings the user has granted to the application will be passed in as the second argument.
    @available(iOS, introduced: 8.0, deprecated: 10.0, message: "Use UserNotification UNNotification Settings instead")
    open func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        ACCApp.mapServices({$0 as? UIApplicationDelegate}).forEach { service in
            service.application?(application, didRegister: notificationSettings)
        }
    }
    
    @available(iOS 3.0, *)
    open func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        ACCApp.mapServices({$0 as? UIApplicationDelegate}).forEach { service in
            service.application?(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
        }
    }
    
    @available(iOS 3.0, *)
    open func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        ACCApp.mapServices({$0 as? UIApplicationDelegate}).forEach { service in
            service.application?(application, didFailToRegisterForRemoteNotificationsWithError: error)
        }
    }
    
    @available(iOS, introduced: 3.0, deprecated: 10.0, message: "Use UserNotifications Framework's -[UNUserNotificationCenterDelegate willPresentNotification:withCompletionHandler:] or -[UNUserNotificationCenterDelegate didReceiveNotificationResponse:withCompletionHandler:] for user visible notifications and -[UIApplicationDelegate application:didReceiveRemoteNotification:fetchCompletionHandler:] for silent remote notifications")
    open func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        ACCApp.mapServices({$0 as? UIApplicationDelegate}).forEach { service in
            service.application?(application, didReceiveRemoteNotification: userInfo)
        }
    }
    
    @available(iOS, introduced: 4.0, deprecated: 10.0, message: "Use UserNotifications Framework's -[UNUserNotificationCenterDelegate willPresentNotification:withCompletionHandler:] or -[UNUserNotificationCenterDelegate didReceiveNotificationResponse:withCompletionHandler:]")
    open func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        ACCApp.mapServices({$0 as? UIApplicationDelegate}).forEach { service in
            service.application?(application, didReceive: notification)
        }
    }
    
    // Called when your app has been activated by the user selecting an action from a local notification.
    // A nil action identifier indicates the default action.
    // You should call the completion handler as soon as you've finished handling the action.
    @available(iOS, introduced: 8.0, deprecated: 10.0, message: "Use UserNotifications Framework's -[UNUserNotificationCenterDelegate didReceiveNotificationResponse:withCompletionHandler:]")
    open func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, for notification: UILocalNotification, completionHandler: @escaping () -> Void) {
        ACCApp.apply({ (service, completion) -> Void? in
            (service as? UIApplicationDelegate)?.application?(
                application,
                handleActionWithIdentifier: identifier,
                for: notification,
                completionHandler: {
                    completion(())
                })
        }, completionHandler: { _ in
            completionHandler()
        })
    }
    
    @available(iOS, introduced: 9.0, deprecated: 10.0, message: "Use UserNotifications Framework's -[UNUserNotificationCenterDelegate didReceiveNotificationResponse:withCompletionHandler:]")
    open func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [AnyHashable: Any], withResponseInfo responseInfo: [AnyHashable: Any], completionHandler: @escaping () -> Void) {
        ACCApp.apply({ (service, completionHandler) -> Void? in
            (service as? UIApplicationDelegate)?.application?(
                application,
                handleActionWithIdentifier: identifier,
                forRemoteNotification: userInfo,
                withResponseInfo: responseInfo,
                completionHandler: {
                    completionHandler(())
                })
        }, completionHandler: { _ in
            completionHandler()
        })
    }
    
    // Called when your app has been activated by the user selecting an action from a remote notification.
    // A nil action identifier indicates the default action.
    // You should call the completion handler as soon as you've finished handling the action.
    @available(iOS, introduced: 8.0, deprecated: 10.0, message: "Use UserNotifications Framework's -[UNUserNotificationCenterDelegate didReceiveNotificationResponse:withCompletionHandler:]")
    open func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [AnyHashable: Any], completionHandler: @escaping () -> Void) {
        ACCApp.apply({ (service, completionHandler) -> Void? in
            (service as? UIApplicationDelegate)?.application?(
                application,
                handleActionWithIdentifier: identifier,
                forRemoteNotification: userInfo,
                completionHandler: {
                    completionHandler(())
                })
        }, completionHandler: { _ in
            completionHandler()
        })
    }
    
    @available(iOS, introduced: 9.0, deprecated: 10.0, message: "Use UserNotifications Framework's -[UNUserNotificationCenterDelegate didReceiveNotificationResponse:withCompletionHandler:]")
    open func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, for notification: UILocalNotification, withResponseInfo responseInfo: [AnyHashable: Any], completionHandler: @escaping () -> Void) {
        ACCApp.apply({ (service, completionHandler) -> Void? in
            (service as? UIApplicationDelegate)?.application?(
                application,
                handleActionWithIdentifier: identifier,
                for: notification,
                withResponseInfo: responseInfo,
                completionHandler: {
                    completionHandler(())
                })
        }, completionHandler: { _ in
            completionHandler()
        })
    }
    
    /*! This delegate method offers an opportunity for applications with the "remote-notification" background mode to fetch appropriate new data in response to an incoming remote notification. You should call the fetchCompletionHandler as soon as you're finished performing that operation, so the system can accurately estimate its power and data cost.
     
     This method will be invoked even if the application was launched or resumed because of the remote notification. The respective delegate methods will be invoked first. Note that this behavior is in contrast to application:didReceiveRemoteNotification:, which is not called in those cases, and which will not be invoked if this method is implemented. !*/
    @available(iOS 7.0, *)
    open func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        ACCApp.apply({ (service, completionHandler) -> Void? in
            (service as? UIApplicationDelegate)?.application?(
                application,
                didReceiveRemoteNotification: userInfo,
                fetchCompletionHandler: completionHandler
            )
        }, completionHandler: { results in
            let result = results.min(by: { $0.rawValue < $1.rawValue }) ?? .noData
            completionHandler(result)
        })
    }
}
#endif
