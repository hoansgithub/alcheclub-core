//
//  ContainerView.swift
//  Example-iOS
//
//  Created by HoanNL on 23/04/2024.
//

import SwiftUI

protocol ContainerViewProtocol: BaseViewProtocol {}

struct ContainerView<VM: ContainerViewModelProtocol>: ContainerViewProtocol {
    var vm: VM
    
    @StateObject var appSession = AppSession.shared
    
    var body: some View {
        ZStack(content: {
            switch appSession.appState {
            case .onboarding:
                OnboardingView(vm: OnboardingViewModel(serviceProvider: vm.serviceProvider)).transition(.move(edge: .leading))
            case .authenticated:
                HomeView(vm: HomeViewModel(serviceProvider: vm.serviceProvider)).transition(.move(edge: .leading))
            case .unauthenticated:
                MainView(vm: MainViewModel(serviceProvider: vm.serviceProvider)).transition(.move(edge: .leading))
            default:
                SplashView(vm: SplashViewModel(serviceProvider: vm.serviceProvider)).transition(.move(edge: .bottom))
            }
        }).animation(.default, value: appSession.appState)
    }
}
