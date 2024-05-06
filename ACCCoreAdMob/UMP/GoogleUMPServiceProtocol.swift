//
//  GoogleUMPServiceProtocol.swift
//  ACCCoreAdMob
//
//  Created by HoanNL on 04/05/2024.
//

import Foundation
import UserMessagingPlatform
import ACCCore
import Combine

public protocol GoogleUMPServiceProtocol: ServiceProtocol {
    var isPrivacyOptionsRequiredPublisher: AnyPublisher<Bool, Never> { get }
    var canRequestAdsPublisher: AnyPublisher<Bool, Never> { get }
    func presentConsentFormIfRequired(from controller: UIViewController) async throws
    func presentPrivacyOptionsForm(from controller: UIViewController) async throws
    #if DEBUG
    func reset()
    #endif
}
