//
//  AdFormatProtocol.swift
//  ACCCoreAdMob
//
//  Created by HoanNL on 07/05/2024.
//

import ACCCore

public protocol AdFormatProtocol: ConfigurableProtocol {
    var adUnitID: String { get }
}
