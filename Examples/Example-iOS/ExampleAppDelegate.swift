//
//  ExampleAppDelegate.swift
//  Example-iOS
//
//  Created by HoanNL on 16/04/2024.
//

import Foundation
import ACCCore
class ExampleAppDelegate: ServiceProviderAppDelegate {
    override init() {
        super.init()
    }
    let sampleService = SampleService()
    override var services: [ServiceProtocol] {
        return [sampleService]
    }
    
}
