//
//  AsyncNetworkHandler.swift
//  ACCCoreNetworking
//
//  Created by HoanNL on 25/6/24.
//

import Foundation

public protocol AsyncNetworkErrorHandler {
    func canHandle(_ error: Error) -> Bool
    func handle(_ error: Error) async throws
}

struct TaskComplete {
    let response: HTTPURLResponse?
    let elapsedTime: TimeInterval?
}
