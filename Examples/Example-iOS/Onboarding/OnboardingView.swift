//
//  OnboardingView.swift
//  Example-iOS
//
//  Created by HoanNL on 23/04/2024.
//

import SwiftUI

protocol OnboardingViewProtocol: BaseViewProtocol {}

struct OnboardingView<VM: OnboardingViewModelProtocol>: OnboardingViewProtocol {
    @StateObject var obManager = OnboardingManager()
    var vm: VM
    var body: some View {
        TabView {
            ForEach(obManager.items) { item in
                OnboardingItemView(item: item, lastItem: obManager.items.last == item, vm: vm)
            }
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
}

struct OnboardingItemView: View {
    let item: OnboardingItem
    let lastItem: Bool
    let vm: any OnboardingViewModelProtocol
    var body: some View {
        VStack(content: {
            Text(item.text)
            if lastItem {
                Button {
                    Task {
                        await vm.closeOnboarding()
                    }
                } label: {
                    Text("GO ->>>")
                }
            }
        })
    }
}
