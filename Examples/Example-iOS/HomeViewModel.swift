//
//  HomeViewModel.swift
//  Example-iOS
//
//  Created by HoanNL on 16/04/2024.
//

import ACCCore
protocol HomeViewModelProtocol: BaseViewModelProtocol {
    var content: String { get }
}

class HomeViewModel: HomeViewModelProtocol {
    @Published var content: String = "ABC"
    
    var serviceProvider: ServiceProviderProtocol
    var sampleService: SampleServiceProtocol?
    
    init(serviceProvider: ServiceProviderProtocol) {
        self.serviceProvider = serviceProvider
        self.sampleService =  serviceProvider.getService(SampleServiceProtocol.self)
    }
    
}
