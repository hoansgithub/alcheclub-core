//
//  GoogleUMPService.swift
//  ACCCoreAdMob
//
//  Created by HoanNL on 04/05/2024.
//

import Foundation
import ACCCore
import UserMessagingPlatform
import Combine

public final class GoogleUMPService: NSObject,@unchecked Sendable , GoogleUMPServiceProtocol {
    public enum GoogleUMPServiceError: Error {
        case consentNotRequired
        case consentObtained
        case consentStatusUnknown
    }
    
    ///Publishers
    private let isPrivacyOptionsRequiredSubject = CurrentValueSubject<Bool, Never>(false)
    public var isPrivacyOptionsRequiredPublisher: AnyPublisher<Bool, Never>
    
    private let canRequestAdsSubject = CurrentValueSubject<Bool, Never>(false)
    public var canRequestAdsPublisher: AnyPublisher<Bool, Never>
    private let stateSubject = CurrentValueSubject<ServiceState, Never>(.idle)
    public var statePublisher: AnyPublisher<ServiceState, Never>
    
    
    ///UMPService
    ///
    public static let defaultRequestParams = {
        // Create a UMPRequestParameters object.
        let parameters = UMPRequestParameters()
        // Set tag for under age of consent. false means users are not under age
        // of consent.
        parameters.tagForUnderAgeOfConsent = false
        return parameters
    }()
    
    public static let defaultDebugSettings = {
        let debugSettings = UMPDebugSettings()
        //        debugSettings.geography = UMPDebugGeography.EEA
        //        debugSettings.testDeviceIdentifiers = ["9685ECD1-B952-4FC0-A54A-D4481ED248B1"]
        return debugSettings
    }()
    
    public var requestParams: UMPRequestParameters
    public var canRequestAds: Bool {
        UMPConsentInformation.sharedInstance.canRequestAds
    }
    
    public var isPrivacyOptionsRequired: Bool {
        UMPConsentInformation.sharedInstance.privacyOptionsRequirementStatus == .required
    }
    
    
    private var serviceStateCancellable: AnyCancellable?
    public required init(parameters: UMPRequestParameters = GoogleUMPService.defaultRequestParams,
                         debugSettings: UMPDebugSettings = GoogleUMPService.defaultDebugSettings) {
        self.isPrivacyOptionsRequiredPublisher = isPrivacyOptionsRequiredSubject
            .removeDuplicates()
            .eraseToAnyPublisher()
        self.canRequestAdsPublisher = canRequestAdsSubject
            .removeDuplicates()
            .eraseToAnyPublisher()
        self.statePublisher = stateSubject
            .removeDuplicates()
            .eraseToAnyPublisher()
        self.requestParams = parameters
        self.requestParams.debugSettings = debugSettings
        super.init()
        
    }
}

extension GoogleUMPService {
    public func presentConsentFormIfRequired(from controller: UIViewController) async throws {
        
        serviceStateCancellable?.cancel()
        
        
        
        @MainActor @Sendable func asyncCheck() async throws {
            switch UMPConsentInformation.sharedInstance.consentStatus {
            case .required, .unknown:
                break
            case .notRequired: throw GoogleUMPServiceError.consentNotRequired
            case .obtained: throw GoogleUMPServiceError.consentObtained
            default: throw GoogleUMPServiceError.consentStatusUnknown
            }
            try await UMPConsentForm.loadAndPresentIfRequired(from: controller)
            isPrivacyOptionsRequiredSubject.send(isPrivacyOptionsRequired)
            canRequestAdsSubject.send(canRequestAds)
        }
        
        return try await withCheckedThrowingContinuation { cont in
            serviceStateCancellable = stateSubject
                .filter({$0 == .ready})
                .prefix(1)
                .sink { _ in
                    Task {
                        do {
                            try await asyncCheck()
                            cont.resume()
                        } catch {
                            cont.resume(throwing: error)
                        }
                    }
                }
        }
    }
    
    @MainActor public func presentPrivacyOptionsForm(from controller: UIViewController) async throws {
        try await UMPConsentForm.presentPrivacyOptionsForm(from: controller)
        canRequestAdsSubject.send(canRequestAds)
    }
    
    #if DEBUG
    public func reset() {
        UMPConsentInformation.sharedInstance.reset()
        isPrivacyOptionsRequiredSubject.send(isPrivacyOptionsRequired)
        canRequestAdsSubject.send(canRequestAds)
    }
    #endif
}


extension GoogleUMPService: UIApplicationDelegate {
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        startService()
        return true
    }
}

private extension GoogleUMPService {
    func startService() {
        Task {
            do {
                try await UMPConsentInformation.sharedInstance.requestConsentInfoUpdate(with: requestParams)
            } catch {
                ACCLogger.print(error.localizedDescription, level: .error)
            }
            isPrivacyOptionsRequiredSubject.send(isPrivacyOptionsRequired)
            canRequestAdsSubject.send(canRequestAds)
            stateSubject.send(.ready)
        }
    }
}
