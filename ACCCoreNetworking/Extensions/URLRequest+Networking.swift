//
//  URLRequest+Networking.swift
//  ACCCoreNetworking
//
//  Created by HoanNL on 25/6/24.
//

import Foundation

var networkRequestObserverStartDateKey: UInt8 = 0

// MARK: - URL Session task did start

let networkTaskDidStartNotification: AsyncNotification<URLSessionDataTask> = AsyncNotification()
let networkTaskDidCompleteNotification: AsyncNotification<TaskComplete> = AsyncNotification()

extension URLRequest: ConvertsToURLRequest {
    public func asURLRequest() -> URLRequest {
        return self
    }
}
