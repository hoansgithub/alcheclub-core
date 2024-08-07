//
//  SampleServiceProtocol.swift
//  Example-iOS
//
//  Created by HoanNL on 16/04/2024.
//

import ACCCore
import Combine
protocol SampleServiceProtocol: ACCService, ServiceStateObservable, ConfigurableObject {
    func getContent() async throws
    var contentPublisher: AnyPublisher<String, Never> { get }
}
