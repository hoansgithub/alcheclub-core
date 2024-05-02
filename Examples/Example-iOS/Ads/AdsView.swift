//
//  AdsView.swift
//  Example-iOS
//
//  Created by HoanNL on 02/05/2024.
//

import SwiftUI
protocol AdsViewProtocol: BaseViewProtocol {}

struct AdsView<VM: AdsViewModelProtocol>: AdsViewProtocol {
    var vm: VM
    
    var body: some View {
        NavigationView(content: {
            List {
                Button("TEEEE") {
                    
                }
            }
        })
    }
}
