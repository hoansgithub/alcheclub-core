//
//  AdsView.swift
//  Example-iOS
//
//  Created by HoanNL on 02/05/2024.
//

import SwiftUI
import ACCCore
import ACCCoreStoreKit
protocol AdsViewProtocol: BaseViewProtocol {}

struct AdsView<VM: AdsViewModelProtocol>: AdsViewProtocol {
    @StateObject var vm: VM
    @State var interstitialDesPresented: Bool = false
    private let formViewControllerRepresentable = BaseViewControllerRepresentable()
    
    var body: some View {
        NavigationLink(destination:
                        StoreContainerView(storeViewModel: $vm.storeViewModel.map({ storeVM in
            if let storeVM = storeVM {
                return storeVM as! StoreViewModel
            } else {
                return StoreViewModel(config: StorePreset.shared.defaultConfig)
            }
        })), isActive: $interstitialDesPresented) {
            EmptyView()
        }
        ScrollView {
            VStack {
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
                
                Button(action: {
                    vm.getNativeAd(for: "AAA", root: formViewControllerRepresentable.viewController)
                }, label: {
                    Text("Get Native Ads")
                })
                .disabled(!vm.adMobReady)
                
                Button(action: {
                    vm.removeNativeAds(for: "AAA")
                }, label: {
                    Text("Remove Native Ads")
                }).disabled(vm.recentNativeAdView == nil)
                
                Button("Remove banner") {
                    vm.removeBannerAd()
                }.disabled(vm.recentBannerAdView == nil)
                
                Button("Show Interstitial") {
                    do {
                        try vm.presentInterstitial(from: formViewControllerRepresentable.viewController) { state in
                            interstitialDesPresented = true
                        }
                    } catch {
                        ACCLogger.print(error, level: .error)
                    }
                }
                
                Button("Show Rewarded") {
                    do {
                        try vm.presentRewarded(from: formViewControllerRepresentable.viewController) { state in
                            switch state {
                            case .rewarded:
                                ACCLogger.print("REWARDED")
                            default: break
                            }
                        }
                    } catch {
                        ACCLogger.print(error, level: .error)
                    }
                }
                
                Button("Show Rewarded Interstitial") {
                    do {
                        try vm.presentRewardedInterstitial(from: formViewControllerRepresentable.viewController) { state in
                            switch state {
                            case .rewarded:
                                ACCLogger.print("REWARDED")
                                interstitialDesPresented = true
                            default: break
                            }
                        }
                    } catch {
                        ACCLogger.print(error, level: .error)
                    }
                }
                
                Button("RESET") {
                    vm.reset()
                }.foregroundStyle(.blue)
                
                if let nativeAdView = vm.recentNativeAdView {
                    BaseNativeAdPresentable(nativeAdView: nativeAdView)
                        .frame( height: 250)
                }
                
                    
            }
            
            
        }
        .background {
            formViewControllerRepresentable
        }
        .navigationTitle("ADS")
        .navigationBarTitleDisplayMode(.large)
        
        BaseUIViewRepresentable(inputUIView: $vm.recentBannerAdView)
            .frame(maxWidth: .infinity,
                   maxHeight: vm.recentBannerAdView?.frame.height ?? 1 ,
                   alignment: .bottom)
            .background(Color.blue)
            .animation(.linear, value: vm.recentBannerAdView?.frame.height)
        
    }
}
