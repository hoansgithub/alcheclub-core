//
//  BaseViewControllerRepresentable.swift
//  Example-iOS
//
//  Created by HoanNL on 06/05/2024.
//

import SwiftUI
import UIKit
@MainActor struct BaseViewControllerRepresentable: UIViewControllerRepresentable {
    let viewController = UIViewController()
    
    func makeUIViewController(context: Context) -> some UIViewController {
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}
