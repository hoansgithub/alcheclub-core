//
//  StoreContainerView.swift
//  Example-iOS
//
//  Created by HoanNL on 8/7/24.
//

import SwiftUI
import ACCCoreStoreKit

struct StoreContainerView: View {
    @Binding var storeViewModel: StoreViewModel?
    var body: some View {
        switch storeViewModel?.config.id {
        case "StoreOneView":
            StoreOneView(vm: $storeViewModel)
        default:
            StoreTwoView(vm: $storeViewModel)
        }
    }
}
