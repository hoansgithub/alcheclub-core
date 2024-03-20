//
//  ServiceProviderAppDelegate+SiriKitHandling.swift
//  VCLCore
//
//  Created by HoanNL on 15/09/2023.
//

import Intents

#if os(iOS)
import UIKit

extension ServiceProviderAppDelegate {
    open func application(_ application: UIApplication, handlerFor intent: INIntent) -> Any? {
        return nil
    }
}

#endif
