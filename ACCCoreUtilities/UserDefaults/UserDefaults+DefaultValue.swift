//
//  UserDefaults+DefaultValue.swift
//  ACCCoreUtilities
//
//  Created by HoanNL on 01/05/2024.
//

import Foundation
@propertyWrapper
public struct UserDefaultProp<Value> {
    public let key: String
    public let defaultValue: Value
    public var container: UserDefaults = .standard
    public init(key: String, defaultValue: Value, container: UserDefaults = .standard) {
        self.key = key
        self.defaultValue = defaultValue
        self.container = container
    }
    
    public var wrappedValue: Value {
        get {
            return container.object(forKey: key) as? Value ?? defaultValue
        }
        set {
            // Check whether we're dealing with an optional and remove the object if the new value is nil.<value>
            if let val = newValue as? Optional<Value.Type>, val == nil  {
                container.removeObject(forKey: key)
            } else {
                container.set(newValue, forKey: key)
            }
        }
    }
    
}
