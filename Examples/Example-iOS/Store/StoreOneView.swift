//
//  StoreOneView.swift
//  Example-iOS
//
//  Created by HoanNL on 4/7/24.
//

import SwiftUI
import ACCCoreStoreKit
struct StoreOneView<VM: StoreViewModel>: View {
    @Binding var vm: VM?
    @State var loading: Bool = false
    var body: some View {
        List(vm?.products ?? []) { product in
            Button(action: {
                Task {
                    loading = true
                    await vm?.purchase(product: product)
                    loading = false
                }
            }, label: {
                if product.purchased {
                    Text("\(product.displayName) - \(product.displayPrice) ✅")
                } else {
                    Text("\(product.displayName) - \(product.displayPrice)")
                }
            }).disabled(product.purchased)
        }
        .navigationTitle("Store One")
        .overlay {
            if loading {
                ProgressView().progressViewStyle(CircularProgressViewStyle())
            }
        }
    }
}
