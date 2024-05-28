//
//  NativeAdReceiver.swift
//  ACCCoreAdMob
//
//  Created by HoanNL on 28/05/2024.
//

import Foundation
import UIKit
public class NativeAdReceiver: NSObject {
    
    public typealias ErrorHandler = (_ error: any Error) -> Void
    
    public typealias TemplateGetter = () -> UIView
    
    public typealias AdViewReceiver = (_ view: UIView) -> Void
    
    
    let errorHandler: ErrorHandler?
    let templateGetter: TemplateGetter?
    let adViewReceiver: AdViewReceiver?
    weak var adLoader: (any NativeAdLoaderProtocol)? = nil
    
    public required init(errorHandler: ErrorHandler? = nil, templateGetter: TemplateGetter?, adViewReceiver: AdViewReceiver?) {
        self.errorHandler = errorHandler
        self.templateGetter = templateGetter
        self.adViewReceiver = adViewReceiver
    }
    
}
