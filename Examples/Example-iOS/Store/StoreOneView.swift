//
//  StoreOneView.swift
//  Example-iOS
//
//  Created by HoanNL on 4/7/24.
//

import SwiftUI
import ACCCoreStoreKit
struct StoreOneView<VM: StoreViewModelProtocol>: View {
    @Binding var vm: VM
    
    var body: some View {
        ZStack(content: {
            List(vm.products) { product in
                Button(action: {
                    Task {
                        
                        await vm.purchase(product: product, accountToken: nil)
                        
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
            
            Button {
                Task {
                    await vm.restore()
                }
            } label: {
                Text("Restore")
            }
        }).alert("Store Error", isPresented: $vm.state.map({ state in
            switch state {
            case .error(err: let err): return true
            default: return false
            }
        })) {
            
        }
        
    }
}

extension StoreKitManagerError {
    var message: String {
        switch self {
        case .productNotFound:
            "Product not found"
        case .userCancelledPurchase:
            "User cancelled purchase"
        case .transactionIsPending:
            "Payment is pending"
        case .canNotRestore:
            "Failed to restore your purchase"
        case .failedVerification:
            "Something went wrong"
        case .unknown:
            "Something went wrong"
        }
    }
}
