//
//  AdsView.swift
//  Example-iOS
//
//  Created by HoanNL on 02/05/2024.
//

import SwiftUI
protocol AdsViewProtocol: BaseViewProtocol {}

struct AdsView<VM: AdsViewModelProtocol>: AdsViewProtocol {
    @StateObject var vm: VM
    private let formViewControllerRepresentable = FormViewControllerRepresentable()
    var body: some View {
        List {
            Text("Can request ads: \(vm.canRequestAds ? "✅" : ".")")
            Text("Admob ready: \(vm.adMobReady ? "✅" : ".")")
            Button {
                vm.presentPrivacyOptions(from: formViewControllerRepresentable.viewController)
            } label: {
                Text("Present privacy options").foregroundStyle(.blue)
            }
            .disabled(!vm.isPrivacyOptionsRequired)
            
            Button {
                Task {
                    await vm.getBannerAd(controller: formViewControllerRepresentable.viewController)
                }
            } label: {
                Text("Get Banner").foregroundStyle(.blue)
            }
            .disabled(!vm.adMobReady)
            
            Button("Remove banner") {
                vm.removeBannerAd()
            }.disabled(vm.recentBannerAdView == nil)
            
            Button("RESET") {
                vm.reset()
            }.foregroundStyle(.blue)
        }
        .navigationTitle("Ads Demo")
        .background {
            formViewControllerRepresentable
                .frame(width: .zero, height: .zero)
        }
        
        BaseUIViewRepresentable(inputUIView: $vm.recentBannerAdView)
            .frame(maxWidth: .infinity,
                   maxHeight: vm.recentBannerAdView?.frame.height ?? 1 ,
                   alignment: .bottom)
            .background(Color.blue)
            .animation(.linear, value: vm.recentBannerAdView?.frame.height)
        
    }
}
