//
//  HomeViewModel.swift
//  Example-iOS
//
//  Created by HoanNL on 16/04/2024.
//

import ACCCore
import Combine
protocol HomeViewModelProtocol: Sendable, BaseViewModelProtocol {
    var content: String { get }
    var loading: Bool { get }
    func onViewAppear()
    func logOut() async
}

class HomeViewModel: @unchecked Sendable, HomeViewModelProtocol {
    @Published var content: String = "ABC"
    @Published var loading = false
    
    
    var sampleService: SampleServiceProtocol?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.sampleService =  ACCApp.getService(SampleServiceProtocol.self)
        self.registerObservers()
    }
    
    func registerObservers() {
        sampleService?.contentPublisher.receive(on: DispatchSerialQueue.main).sink(receiveValue: { [weak self] aaa in
            self?.content = aaa
        }).store(in: &cancellables)
    }
    
    func onViewAppear() {
        
    }
    
    @MainActor func logOut() {
        AppSession.shared.logout()
    }
    
    deinit {
        ACCLogger.print(self)
    }
}
