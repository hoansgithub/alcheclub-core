//
//  SampleService.swift
//  Example-iOS
//
//  Created by HoanNL on 16/04/2024.
//

import Foundation
import UIKit
class SampleService: NSObject, SampleServiceProtocol {
    var defaultValue = "ABC"
    override init() {
        super.init()
        
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        self.defaultValue = "DEF"
        return true
    }
    
    @MainActor func getContent() async throws -> String {
        guard let myURL = URL(string: "https://google.com") else {
            return "unknown"
        }
        
        let (data, _) = try await URLSession.shared.data(from: myURL)
        let str = data.base64EncodedString()
        try await Task.sleep(nanoseconds: 3_000_000_000)
        return str
    }
}
