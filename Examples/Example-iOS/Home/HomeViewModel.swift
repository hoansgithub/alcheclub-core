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
    var latestError: Error? { get set }
    var userProfile: FBUserProfile? { get }
    func onViewAppear() async
    func logOut() async
}

class HomeViewModel: @unchecked Sendable, HomeViewModelProtocol {
    @Published var content: String = "ABC"
    @Published var loading = false
    @Published var userProfile: FBUserProfile?
    @Published var latestError: Error?
    var sampleService: SampleServiceProtocol?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.sampleService =  ACCApp.getService(SampleServiceProtocol.self)
        self.registerObservers()
    }
    
    func registerObservers() {
        sampleService?.contentPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] aaa in
                self?.content = aaa
            }).store(in: &cancellables)
    }
    
    @MainActor func onViewAppear() {
        Task {
            do {
                userProfile = try await TeslaService.shared.getProfile()
            } catch {
                ACCLogger.print(error, level: .error)
                latestError = error
            }
        }
    }
    
    @MainActor func logOut() {
        AppSession.shared.loggedOut()
    }
    
    deinit {
        ACCLogger.print(self)
    }
}
