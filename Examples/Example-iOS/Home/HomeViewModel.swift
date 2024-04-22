//
//  HomeViewModel.swift
//  Example-iOS
//
//  Created by HoanNL on 16/04/2024.
//

import ACCCore
import Combine
protocol HomeViewModelProtocol: BaseViewModelProtocol {
    var content: String { get }
    var loading: Bool { get }
    func onViewAppear()
}

class HomeViewModel: @unchecked Sendable, HomeViewModelProtocol {
    @Published var content: String = "ABC"
    @Published var loading = false
    
    
    var serviceProvider: ServiceProviderAppDelegate
    var sampleService: SampleServiceProtocol?
    private var cancellables = Set<AnyCancellable>()
    
    init(serviceProvider: ServiceProviderAppDelegate) {
        self.serviceProvider = serviceProvider
        self.sampleService =  serviceProvider.getService(SampleServiceProtocol.self)
        registerObservers()
    }
    
    func registerObservers() {
        sampleService?.contentPublisher.receive(on: DispatchSerialQueue.main).sink(receiveValue: { [weak self] aaa in
            self?.content = aaa
        }).store(in: &cancellables)
    }
    
    func onViewAppear() {
       
    }
    
    deinit {
        debugPrint("\(self) deinit")
    }
}
