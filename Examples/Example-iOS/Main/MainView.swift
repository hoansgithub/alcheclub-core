//
//  MainView.swift
//  Example-iOS
//
//  Created by HoanNL on 17/04/2024.
//

import SwiftUI
import ACCCore
import ACCCoreUtilities
import ACCCoreStoreKit
protocol MainViewProtocol: BaseViewProtocol {}

struct MainView<VM: MainViewModelProtocol>: MainViewProtocol {
    @StateObject var vm: VM
    var body: some View {
        NavigationView(content: {
            List {
                NavigationLink(destination: AdsView(vm: AdsViewModel())) {
                    Text("ADS")
                }
                Button("Push store") {
                    vm.toggleStoreViewModel(identifier: "StoreOneView")
                }
                
                
                NavigationLink(destination:
                                StoreContainerView(storeViewModel: $vm.storeViewModel.map({ storeVM in
                    if let storeVM = storeVM {
                        return storeVM
                    } else {
                        return StoreViewModel(config: StorePreset.shared.defaultConfig)
                    }
                })), isActive: $vm.storeViewModel.map({$0 != nil})) {
                    EmptyView()
                }
                
                Button("Firebase Messaging") {
                    vm.requestNotiPermission()
                }.disabled(!vm.notificationPermissionNeeded)
                
                Button("Login") {
                    Task {
                        await vm.login()
                    }
                }
                
                Button("Track Event") {
                    vm.track(event: AnalyticsEvent("test_event_name", params: ["value" : "test_param_value"]))
                }
                
                Button("Onboarding") {
                    Task {
                        await vm.goToOnboarding()
                    }
                }
                
                Spacer()
                Button("CRASH") {
                    fatalError("Crash was triggered")
                }
                Spacer()
                Text(vm.notiUserInfo["test_data"] as? String ?? "")
                Text("APN Token " + vm.notiToken)
                
            }
        })
        
    }
}
