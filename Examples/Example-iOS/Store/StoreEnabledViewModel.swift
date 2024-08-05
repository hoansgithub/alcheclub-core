//
//  StoreEnabledViewModel.swift
//  Example-iOS
//
//  Created by HoanNL on 8/7/24.
//

import Foundation
import ACCCoreStoreKit
import Combine
protocol StoreEnabledViewModel where Self: ObservableObject {
    var defaultStoreConfig: StoreViewModelConfig { get }
    var storeViewModel: StoreViewModelProtocol? { get set }
    var storeService: StoreServiceProtocol? { get }
}

extension StoreEnabledViewModel {
    func toggleStoreViewModel(identifier: String) {
        storeViewModel = storeService?.getViewModel(for: identifier, defaultConfig: defaultStoreConfig)
    }
}
