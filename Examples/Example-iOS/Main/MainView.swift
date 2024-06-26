//
//  MainView.swift
//  Example-iOS
//
//  Created by HoanNL on 17/04/2024.
//

import SwiftUI
import ACCCore

protocol MainViewProtocol: BaseViewProtocol {}

struct MainView<VM: MainViewModelProtocol>: MainViewProtocol {
    @StateObject var vm: VM
    var body: some View {
        NavigationView(content: {
            List {
                NavigationLink(destination: AdsView(vm: AdsViewModel())) {
                    Text("ADS")
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
