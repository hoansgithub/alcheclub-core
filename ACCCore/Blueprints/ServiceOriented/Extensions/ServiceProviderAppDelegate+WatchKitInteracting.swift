//
//  ServiceProviderAppDelegate+WatchKitInteracting.swift
//  VCLCore
//
//  Created by HoanNL on 15/09/2023.
//

#if os(iOS)
import UIKit

extension ServiceProviderAppDelegate {

    @available(iOS 8.2, *)
    open func application(_ application: UIApplication, handleWatchKitExtensionRequest userInfo: [AnyHashable: Any]?, reply: @escaping ([AnyHashable: Any]?) -> Void) {
        for service in services {
            service.appDelegate?.application?(application, handleWatchKitExtensionRequest: userInfo, reply: reply)
        }
        apply({ (service, reply) -> Void? in
            service.appDelegate?.application?(application, handleWatchKitExtensionRequest: userInfo, reply: reply)
        }, completionHandler: { results in
            let result = results.reduce([:], { initial, next in
                var initial = initial
                for (key, value) in next ?? [:] {
                    initial[key] = value
                }
                return initial
            })
            reply(result)
        })
    }
}

#endif
