//
//  SampleService.swift
//  Example-iOS
//
//  Created by HoanNL on 16/04/2024.
//

import Foundation
import UIKit
import Combine
import ACCCore

final class SampleService: NSObject,@unchecked Sendable, SampleServiceProtocol {
    
    private let contentSubject = CurrentValueSubject<String, Never>("ABC")
    let contentPublisher: AnyPublisher<String, Never>
    
    private let stateSubject = CurrentValueSubject<ServiceState, Never>(.idle)
    let statePublisher: AnyPublisher<ServiceState, Never>
    private var timerCancellable: AnyCancellable?
    
    override init() {
        contentPublisher = contentSubject.eraseToAnyPublisher()
        statePublisher = stateSubject.eraseToAnyPublisher()
        super.init()
    }
    
    
    
    func getContent() async throws {
        guard let myURL = URL(string: "https://google.com") else {
            contentSubject.send("unknown")
            return
        }
        let (data, _) = try await URLSession.shared.getData(for: myURL)
        _ = data.base64EncodedString()
        
        try await Task.sleep(nanoseconds: 1_000_000_000)
        contentSubject.send(UUID().uuidString)
    }
    
    func startTimer() {
        timerCancellable = Timer.publish(every: 2, on: .main, in: .common)
                    .autoconnect()
                    .sink(receiveValue: { [weak self] _ in
                        self?.contentSubject.send(UUID().uuidString)
                    })
    }
}

extension SampleService: UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        contentSubject.send("DEF")
        stateSubject.send(.launching)
        Task {
            try await getContent()
            async let backgroundString1 = doStOnBackground()
            async let backgroundString2 = doStOnBackground()
            let res = try await [backgroundString1, backgroundString2]
            ACCLogger.print("Result from BG \(res)")
            contentSubject.send(res.joined(separator: ","))
            startTimer()
            stateSubject.send(.ready)
            try await Task.sleep(nanoseconds: 10_000_000_000)
            timerCancellable = nil
        }
        
        
        return true
    }
}

private extension SampleService {
    func doStOnBackground() async throws -> String {
        let task = Task.detached(priority: .background) {() -> String in
            let randomSec: UInt64 = (1...5).randomElement() ?? 1
            try await Task.sleep(nanoseconds: randomSec * 3_000_000_000)
            ACCLogger.print("doStOnBackground in \(randomSec)")
            return UUID().uuidString
        }
        
        return try await task.value
    }
}

