//
//  FirebaseRemoteConfigService.swift
//  ACCCoreFirebase
//
//  Created by HoanNL on 19/04/2024.
//

import Foundation
import ACCCore
import Combine
import FirebaseRemoteConfig

public enum FirebaseRemoteConfigServiceError: Error {
    case unknown, noFetchYet, failure, throttled, unableToActivate
    init(firStatus: RemoteConfigFetchStatus) {
        switch firStatus {
        case .noFetchYet:
            self = .noFetchYet
        case .failure:
            self = .failure
        case .throttled:
            self = .throttled
        case .success:
            self = .unknown
        @unknown default:
            self = .unknown
        }
    }
}

public final class FirebaseRemoteConfigService: NSObject, @unchecked Sendable, FirebaseRemoteConfigServiceProtocol {
    private let stateSubject = CurrentValueSubject<ServiceState, Never>(.idle)
    public let statePublisher: AnyPublisher<ServiceState, Never>
    
    private var remoteConfig: RemoteConfig
    nonisolated required public init(coreService: FirebaseCoreServiceProtocol,
                                     settings: RemoteConfigSettings,
                                     defaultPlist: String,
                                     realtimeEnabled: Bool) {
        self.statePublisher = stateSubject.removeDuplicates().eraseToAnyPublisher()
        self.remoteConfig = RemoteConfig.remoteConfig()
        self.remoteConfig.configSettings = settings
        self.remoteConfig.setDefaults(fromPlist: defaultPlist)
        super.init()
    }
}

private extension FirebaseRemoteConfigService {
    func startFetching() async throws {
        Task.detached(priority: .background) { [weak self] () in
            guard let self else { throw FirebaseRemoteConfigServiceError.unknown }
            let status = try await self.remoteConfig.fetch()
            switch status {
            case .success:
                let activated = try await self.remoteConfig.activate()
                if !activated {
                    self.stateSubject.send(.ready)
                } else {
                    throw FirebaseRemoteConfigServiceError.unableToActivate
                }
            default: throw FirebaseRemoteConfigServiceError(firStatus: status)
            }
        }
    }
}

extension FirebaseRemoteConfigService: UIApplicationDelegate {
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        Task {
            try await startFetching()
        }
        return true
    }
}

//extension RemoteConfig: ConfigObject, @unchecked Sendable {
//    public subscript<T>(dynamicMember key: String) -> T {
//        get {
//            
//        }
//    }
//    
//    
//}
