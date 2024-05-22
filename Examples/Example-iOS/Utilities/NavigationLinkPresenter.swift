//
//  NavigationLinkPresenter.swift
//  Example-iOS
//
//  Created by HoanNL on 02/05/2024.
//

import SwiftUI
//handle NavigationLink Pop-back deallocation
//https://stackoverflow.com/questions/61448125/swiftui-pop-back-in-navigation-stack-does-not-deallocate-a-view
struct NavigationLinkPresenter<Content: View>: View {
    let content: () -> Content

    @State private var invalidated = false
    init(@ViewBuilder _ content: @escaping () -> Content) {
        self.content = content
    }
    var body: some View {
        Group {
            if self.invalidated {
                EmptyView()
            } else {
                content()
            }
        }
        .onDisappear {
            self.invalidated = true
        }
        .onAppear  {
            self.invalidated = false
        }
    }
}
