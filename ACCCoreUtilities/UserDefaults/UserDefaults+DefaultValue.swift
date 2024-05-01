//
//  UserDefaults+DefaultValue.swift
//  ACCCoreUtilities
//
//  Created by HoanNL on 01/05/2024.
//

import Foundation
@propertyWrapper
struct UserDefaultProp<Value> {
    let key: String
    let defaultValue: Value
    var container: UserDefaults = .standard
    
    var wrappedValue: Value {
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
