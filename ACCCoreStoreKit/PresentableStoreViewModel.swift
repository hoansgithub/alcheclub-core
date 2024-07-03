//
//  PresentableStoreViewModel.swift
//  ACCCoreStoreKit
//
//  Created by HoanNL on 3/7/24.
//

import Foundation
open class PresentableStoreViewModel: ObservableObject {
    @Published private(set) var products: [PresentableProduct] = []
}
