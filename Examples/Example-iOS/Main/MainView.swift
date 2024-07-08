//
//  MainView.swift
//  Example-iOS
//
//  Created by HoanNL on 17/04/2024.
//

import SwiftUI
import ACCCore

protocol MainViewProtocol: BaseViewProtocol {}
extension Binding {
    func map<NewValue>(_ transform: @escaping (Value) -> NewValue) -> Binding<NewValue> {
        Binding<NewValue>(get: { transform(wrappedValue) }, set: { _ in })
    }
}
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
                                StoreContainerView(storeViewModel: $vm.storeViewModel), isActive: $vm.storeViewModel.map({$0 != nil})) {
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
