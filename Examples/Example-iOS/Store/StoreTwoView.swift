//
//  StoreTwoView.swift
//  Example-iOS
//
//  Created by HoanNL on 8/7/24.
//

import SwiftUI
import ACCCoreStoreKit
struct StoreTwoView<VM: StoreViewModel>: View {
    @Binding var vm: VM
    var body: some View {
        List(vm.products) { product in
            Button(action: {
                
            }, label: {
                if product.purchased {
                    Text("\(product.displayName) - \(product.displayPrice) ✅")
                } else {
                    Text("\(product.displayName) - \(product.displayPrice)")
                }
            }).disabled(product.purchased)
        }.navigationTitle("Store Two")
    }
}
