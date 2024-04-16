//
//  BaseView.swift
//  Example-iOS
//
//  Created by HoanNL on 16/04/2024.
//

import SwiftUI

@MainActor protocol BaseViewProtocol : View {
    associatedtype VM: BaseViewModelProtocol
    var vm: VM { get }
}
