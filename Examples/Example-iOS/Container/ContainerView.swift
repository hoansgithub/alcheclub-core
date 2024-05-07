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
                OnboardingView(vm: OnboardingViewModel()).transition(.move(edge: .leading))
            case .authenticated:
                HomeView(vm: HomeViewModel()).transition(.move(edge: .leading))
            case .unauthenticated:
                MainView(vm: MainViewModel()).transition(.move(edge: .leading))
            default:
                SplashView(vm: SplashViewModel()).transition(.move(edge: .bottom))
            }
        }).animation(.default, value: appSession.appState)
    }
}
