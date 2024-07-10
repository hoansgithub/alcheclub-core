//
//  Binding+Ext.swift
//  ACCCoreUtilities
//
//  Created by HoanNL on 10/7/24.
//

import SwiftUI
public extension Binding {
    func map<NewValue>(_ transform: @escaping (Value) -> NewValue) -> Binding<NewValue> {
        Binding<NewValue>(get: { transform(wrappedValue) }, set: { _ in })
    }
}
