//
//  SampleService.swift
//  Example-iOS
//
//  Created by HoanNL on 16/04/2024.
//

import Foundation
import UIKit
import Combine

final class SampleService: NSObject, Sendable, SampleServiceProtocol {
    
    private let contentSubject = CurrentValueSubject<String, Never>("ABC")
    let contentPublisher: AnyPublisher<String, Never>
    
    override init() {
        contentPublisher = contentSubject.eraseToAnyPublisher()
        super.init()
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        contentSubject.send("DEF")
        Task {
            try await getContent()
        }
        return true
    }
    
    func getContent() async throws {
        guard let myURL = URL(string: "https://google.com") else {
            contentSubject.send("unknown")
            return
        }
        let (data, _) = try await URLSession.shared.getData(for: myURL)
        _ = data.base64EncodedString()
        try await Task.sleep(nanoseconds: 3_000_000_000)
        contentSubject.send(UUID().uuidString)
    }
}



