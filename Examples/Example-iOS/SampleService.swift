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
import ACCCoreUtilities
import ACCCoreAdMob


final class SampleService: NSObject,@unchecked Sendable, SampleServiceProtocol {
    
    private let contentSubject = CurrentValueSubject<String, Never>("ABC")
    let contentPublisher: AnyPublisher<String, Never>
    
    private let stateSubject = CurrentValueSubject<ServiceState, Never>(.idle)
    let statePublisher: AnyPublisher<ServiceState, Never>
    private var timerCancellable: AnyCancellable?
    private var adService: AdServiceProtocol?
    private var initCancellables: Set<AnyCancellable> = []
    
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

extension SampleService: UIWindowSceneDelegate {
    func sceneDidBecomeActive(_ scene: UIScene) {
        
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
            contentSubject.send(res.joined(separator: ","))
            startTimer()
            stateSubject.send(.ready)
            try await Task.sleep(nanoseconds: 10_000_000_000)
            timerCancellable = nil
        }
        
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
    }
    
}

private extension SampleService {
    func doStOnBackground() async throws -> String {
        let task = Task.detached(priority: .background) {() -> String in
            let randomSec: UInt64 = (1...5).randomElement() ?? 1
            try await Task.sleep(nanoseconds: randomSec * 3_000_000_000)
            return UUID().uuidString
        }
        
        return try await task.value
    }
}

struct SampleCodableStruct: Codable {
    var name: String
    var rating: Float
}

///conforming configurable protocol
extension SampleService {
    func update(with config: ConfigObject) {
        /*
         test_key_bool
         true

         test_key_float
         3.5

         test_key_int
         -3

         test_key_json
         {"name":"Hoan","rating":3.5}

         test_key_string
         test_key_string
         
         test_key_uint
         33
         
         */
        let boolVal: Bool? = config["test_key_bool"]
        let floatVal: Float? = config["test_key_float"]
        let intVal: Int? = config["test_key_int"]
        let jsonVal: SampleCodableStruct? = config["test_key_json"]
        let uintVal: UInt? = config["test_key_uint"]
        let stringVal: String? = config["test_key_string"]
        
        ACCLogger.print(boolVal, level: .info)
        ACCLogger.print(floatVal, level: .info)
        ACCLogger.print(intVal, level: .info)
        ACCLogger.print(jsonVal, level: .info)
        ACCLogger.print(uintVal, level: .info)
        ACCLogger.print(stringVal, level: .info)
    }
}
