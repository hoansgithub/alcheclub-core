//
//  ContainerViewModel.swift
//  Example-iOS
//
//  Created by HoanNL on 23/04/2024.
//

import Foundation
import ACCCore
protocol ContainerViewModelProtocol: BaseViewModelProtocol {}

class ContainerViewModel: ContainerViewModelProtocol {
    deinit {
        ACCLogger.print(self)
    }
}
