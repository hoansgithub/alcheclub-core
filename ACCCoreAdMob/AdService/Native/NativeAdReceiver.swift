//
//  NativeAdReceiver.swift
//  ACCCoreAdMob
//
//  Created by HoanNL on 28/05/2024.
//

import Foundation
import UIKit
public class NativeAdReceiver: NSObject, @unchecked Sendable {
    
    public typealias ErrorHandler = @Sendable (_ error: any Error) -> Void
    
    public typealias TemplateGetter = @Sendable () -> UIView?
    
    public typealias AdViewReceiver = @Sendable (_ views: [UIView]) -> Void
    
    public typealias StarRatingImage = @Sendable (_ starRating: NSDecimalNumber) -> UIImage?
    
    internal var adViews: [UIView] = []
    
    let errorHandler: ErrorHandler?
    let templateGetter: TemplateGetter?
    let starRatingImage: StarRatingImage?
    let adViewReceiver: AdViewReceiver?
    weak var adLoader: (any NativeAdLoader)? = nil
    
    public required init(templateGetter: TemplateGetter?, adViewReceiver: AdViewReceiver?, starRatingImage: StarRatingImage? = nil, errorHandler: ErrorHandler? = nil) {
        self.errorHandler = errorHandler
        self.templateGetter = templateGetter
        self.adViewReceiver = adViewReceiver
        self.starRatingImage = starRatingImage
    }
    
}
