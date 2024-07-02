//
//  HomeView.swift
//  Example-iOS
//
//  Created by HoanNL on 16/04/2024.
//

import SwiftUI

protocol HomeViewProtocol: BaseViewProtocol {
    
}

struct HomeView<VM: HomeViewModelProtocol>: HomeViewProtocol {
    @StateObject var vm: VM
    @State var num: Int = 1
    var body: some View {
        VStack(content: {
            AsyncImage(url: URL(string: vm.userProfile?.user.avatar ?? ""), scale: 1)
                .frame(width: 64, height: 64)
                        .clipShape(.rect(cornerRadius: 25))
            Button {
                num += 1
            } label: {
                Text("num \(num)")
            }

            Text(vm.content)
            
            Button {
                Task {
                    await vm.logOut()
                }
            } label: {
                Text("Log out")
            }
        }).onAppear {
            Task {
                await vm.onViewAppear()
            }
        }.errorAlert(error: $vm.latestError)
    }
    
    
}

extension View {
    func errorAlert(error: Binding<Error?>, buttonTitle: String = "OK") -> some View {
        let localizedAlertError = LocalizedAlertError(error: error.wrappedValue)
        return alert(isPresented: .constant(localizedAlertError != nil), error: localizedAlertError) { _ in
            Button(buttonTitle) {
                error.wrappedValue = nil
            }
        } message: { error in
            Text(error.recoverySuggestion ?? "")
        }
    }
}

struct LocalizedAlertError: LocalizedError {
    let underlyingError: LocalizedError
    var errorDescription: String? {
        underlyingError.errorDescription
    }
    var recoverySuggestion: String? {
        underlyingError.recoverySuggestion
    }

    init?(error: Error?) {
        guard let localizedError = error as? LocalizedError else { return nil }
        underlyingError = localizedError
    }
}
