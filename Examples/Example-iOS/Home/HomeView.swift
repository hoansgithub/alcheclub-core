//
//  HomeView.swift
//  Example-iOS
//
//  Created by HoanNL on 16/04/2024.
//

import SwiftUI

protocol HomeViewProtocol: BaseViewProtocol {
    
}

struct HomeView<VM: HomeViewModelProtocol>: HomeViewProtocol {
    @StateObject var vm: VM
    @State var num: Int = 1
    var body: some View {
        VStack(content: {
            Button {
                num += 1
            } label: {
                Text("num \(num)")
            }

            Text(vm.content)
                .onAppear {
                    vm.onViewAppear()
                }
            
            Button {
                Task {
                    await vm.logOut()
                }
            } label: {
                Text("Log out")
            }
        })
    }
    
    
}
