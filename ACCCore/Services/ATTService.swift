//
//  ATTService.swift
//  ACCCore
//
//  Created by HoanNL on 02/05/2024.
//

import Foundation
import Combine
import AppTrackingTransparency
public final class ATTService: NSObject, ATTServiceProtocol {
    //publishers
    private let stateSubject = CurrentValueSubject<ServiceState, Never>(.idle)
    public let statePublisher: AnyPublisher<ServiceState, Never>
    
    nonisolated required public override init() {
        self.statePublisher = stateSubject.removeDuplicates().eraseToAnyPublisher()
        super.init()
    }
    
}

public extension ATTService {
    func requestTrackingAuthorization() {
        ATTrackingManager.requestTrackingAuthorization { stt in
            
        }
    }
}


