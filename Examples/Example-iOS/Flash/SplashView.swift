//
//  SplashView.swift
//  Example-iOS
//
//  Created by HoanNL on 23/04/2024.
//

import SwiftUI

protocol SplashViewProtocol: BaseViewProtocol {}

struct SplashView<VM: SplashViewModelProtocol>: SplashViewProtocol {
    var vm: VM
    var body: some View {
        VStack(content: {
            Text("Splash")
            ProgressView()
                .progressViewStyle(.circular)
                .scaleEffect(2.0, anchor: .center)
            
        }).onAppear(perform: {
            vm.onViewAppear()
        })
        
    }
}
