//
//  ServiceProviderAppDelegate+DownloadingData.swift
//  ACCCore
//
//  Created by HoanNL on 15/09/2023.
//

#if os(iOS)
import UIKit

extension ServiceProviderAppDelegate {

    // Applications using an NSURLSession with a background configuration may be launched or resumed in the background in order to handle the
    // completion of tasks in that session, or to handle authentication. This method will be called with the identifier of the session needing
    // attention. Once a session has been created from a configuration object with that identifier, the session's delegate will begin receiving
    // callbacks. If such a session has already been created (if the app is being resumed, for instance), then the delegate will start receiving
    // callbacks without any action by the application. You should call the completionHandler as soon as you're finished handling the callbacks.
    @available(iOS 7.0, *)
    open func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        apply({ (service, completionHandler) -> Void? in
            (service as? UIApplicationDelegate)?.application?(
                application,
                handleEventsForBackgroundURLSession: identifier,
                completionHandler: {
                    completionHandler(())
            })
        }, completionHandler: { _ in
            completionHandler()
        })
    }
}

#endif
