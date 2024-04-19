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
                NavigationLink(destination: HomeView(vm: HomeViewModel(serviceProvider: vm.serviceProvider))) {
                    Text("HOME")
                }
                Divider()
                Button("Event track") {
                    vm.track(event: AnalyticsEvent("test_event_name", params: ["test_param_key" : "test_param_value"]))
                }
                Divider()
                Button("CRASH") {
                    fatalError("Crash was triggered")
                }
            }
        })
    }
}
