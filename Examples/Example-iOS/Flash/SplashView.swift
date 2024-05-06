//
//  SplashView.swift
//  Example-iOS
//
//  Created by HoanNL on 23/04/2024.
//

import SwiftUI
import UIKit
protocol SplashViewProtocol: BaseViewProtocol {}

struct SplashView<VM: SplashViewModelProtocol>: SplashViewProtocol {
    var vm: VM
    private let formViewControllerRepresentable = FormViewControllerRepresentable()
    @State private var hasViewAppeared = false
    
    var body: some View {
        VStack(content: {
            Text("Splash")
            ProgressView()
                .progressViewStyle(.circular)
                .scaleEffect(2.0, anchor: .center)
            
        }).background {
            // Add the ViewControllerRepresentable to the background so it
            // doesn't influence the placement of other views in the view hierarchy.
            formViewControllerRepresentable
                .frame(width: .zero, height: .zero)
        }.onAppear(perform: {
            if !hasViewAppeared {
                hasViewAppeared = true
                Task {
                    await vm.presentConsentFormIfRequired(vc:formViewControllerRepresentable.viewController)
                    await vm.onViewAppear()
                }
            }
        })
        
    }
}


