//
//  ContainerViewModel.swift
//  Example-iOS
//
//  Created by HoanNL on 23/04/2024.
//

import Foundation
import ACCCore
protocol ContainerViewModelProtocol: BaseViewModelProtocol {}

class ContainerViewModel: ContainerViewModelProtocol {
    var serviceProvider: ServiceProviderAppDelegate
    
    init(serviceProvider: ServiceProviderAppDelegate) {
        self.serviceProvider = serviceProvider
    }
    
    
    deinit {
        ACCLogger.print(self)
    }
}
