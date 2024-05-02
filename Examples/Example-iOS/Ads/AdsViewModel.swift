//
//  AdsViewModel.swift
//  Example-iOS
//
//  Created by HoanNL on 02/05/2024.
//

import Foundation
import ACCCore
protocol AdsViewModelProtocol: BaseViewModelProtocol {
    
}

class AdsViewModel: AdsViewModelProtocol {
    var serviceProvider: ServiceProviderAppDelegate
    
    init(serviceProvider: ServiceProviderAppDelegate) {
        self.serviceProvider = serviceProvider
    }
    
    deinit {
        ACCLogger.print(self)
    }
}
