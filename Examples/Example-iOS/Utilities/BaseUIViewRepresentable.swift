//
//  BaseUIViewRepresentable.swift
//  Example-iOS
//
//  Created by HoanNL on 06/05/2024.
//

import SwiftUI
import UIKit
struct BaseUIViewRepresentable: UIViewRepresentable {
    @Binding var inputUIView: UIView?
    
    func makeUIView(context: Context) -> UIView {
        UIView()
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        uiView.subviews.forEach { v in
            v.removeFromSuperview()
        }
        
        if let inputUIView = inputUIView {
            uiView.addSubview(inputUIView)
        }
    }
}

