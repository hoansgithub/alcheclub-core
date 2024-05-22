//
//  AppEnvironment.swift
//  ACCCore
//
//  Created by HoanNL on 03/05/2024.
//

import Foundation

public final class AppEnvironment: Sendable {
    // MARK: Public
    public static let shared = AppEnvironment()
    
    private init() {}
    func isRunningInTestFlightEnvironment() -> Bool {
        if isSimulator() {
            return false
        } else {
            if isAppStoreReceiptSandbox() && !hasEmbeddedMobileProvision() {
                return true
            } else {
                return false
            }
        }
    }
    
    
    public func isSimulator() -> Bool {
        
#if targetEnvironment(simulator)
        return true
#else
        return false
#endif
    }
    
    func isRunningInAppStoreEnvironment() -> Bool {
        if isSimulator(){
            return false
        } else {
            if isAppStoreReceiptSandbox() || hasEmbeddedMobileProvision() {
                return false
            } else {
                return true
            }
        }
    }
    
    // MARK: Private
    private func hasEmbeddedMobileProvision() -> Bool {
        guard Bundle.main.path(forResource: "embedded", ofType: "mobileprovision") == nil else {
            return true
        }
        return false
    }
    
    private func isAppStoreReceiptSandbox() -> Bool {
        
        if isSimulator() {
            return false
        } else {
            guard let url = Bundle.main.appStoreReceiptURL else {
                return false
            }
            guard url.lastPathComponent == "sandboxReceipt" else {
                return false
            }
            return true
        }
    }

}
