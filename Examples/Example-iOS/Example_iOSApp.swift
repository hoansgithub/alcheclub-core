//
//  Example_iOSApp.swift
//  Example-iOS
//
//  Created by HoanNL on 19/03/2024.
//

import SwiftUI
import ACCCore
@main
struct Example_iOSApp: App {
    @UIApplicationDelegateAdaptor(ExampleAppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            HomeView(vm: HomeViewModel(serviceProvider: delegate))
        }
    }
}
