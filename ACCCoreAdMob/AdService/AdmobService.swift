//
//  AdmobService.swift
//  ACCCoreAdMob
//
//  Created by HoanNL on 07/05/2024.
//

import ACCCore
import Combine
public final class AdmobService: NSObject, AdServiceProtocol {
    //publishers
    private let stateSubject = CurrentValueSubject<ServiceState, Never>(.idle)
    public let statePublisher: AnyPublisher<ServiceState, Never>
    
    //dependencies
    private var umpService: GoogleUMPServiceProtocol
    nonisolated required public init(umpService: GoogleUMPServiceProtocol) {
        self.umpService = umpService
        self.statePublisher = stateSubject.removeDuplicates().eraseToAnyPublisher()
        super.init()
    }
    
}
