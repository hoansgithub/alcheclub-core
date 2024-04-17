//
//  MainViewModel.swift
//  Example-iOS
//
//  Created by HoanNL on 17/04/2024.
//

import Foundation
import ACCCore
protocol MainViewModelProtocol: BaseViewModelProtocol {}

class MainViewModel: MainViewModelProtocol {
    var serviceProvider: ServiceProviderProtocol
    init(serviceProvider: ServiceProviderProtocol) {
        self.serviceProvider = serviceProvider
    }
}
