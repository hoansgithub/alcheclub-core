//
//  BaseNativeAdPresentable.swift
//  Example-iOS
//
//  Created by HoanNL on 21/6/24.
//

import Foundation
import SwiftUI
import UIKit

struct BaseNativeAdPresentable: UIViewRepresentable {
    var nativeAdView: UIView
    func makeUIView(context: Context) -> UIView {
        UIView()
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        uiView.subviews.forEach { v in
            v.removeFromSuperview()
        }
        uiView.addSubview(nativeAdView)
        
        nativeAdView.translatesAutoresizingMaskIntoConstraints = false
        
        let viewDictionary = ["_nativeAdView": nativeAdView]
        uiView.addConstraints(
          NSLayoutConstraint.constraints(
            withVisualFormat: "H:|[_nativeAdView]|",
            options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewDictionary)
        )
        uiView.addConstraints(
          NSLayoutConstraint.constraints(
            withVisualFormat: "V:|[_nativeAdView]|",
            options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewDictionary)
        )
    }
}
