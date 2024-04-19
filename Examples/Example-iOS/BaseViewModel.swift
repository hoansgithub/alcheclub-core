//
//  BaseViewModel.swift
//  Example-iOS
//
//  Created by HoanNL on 16/04/2024.
//

import Foundation
import ACCCore
protocol BaseViewModelProtocol: ObservableObject {
    var serviceProvider: ServiceProviderAppDelegate { get }
}
