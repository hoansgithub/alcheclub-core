//
//  HomeView.swift
//  Example-iOS
//
//  Created by HoanNL on 16/04/2024.
//

import SwiftUI

protocol HomeViewProtocol: BaseViewProtocol {
    
}

struct HomeView<VM: HomeViewModel>: HomeViewProtocol {
    @ObservedObject var vm: VM
    
    var body: some View {
        Text(vm.content)
            .onAppear {
                Task {
                    try? await vm.getContent()
                }
            }
    }
    
    
}
