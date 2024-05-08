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
    case unknown, noFetchYet, failure, throttled
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

public final class FirebaseRemoteConfigService: NSObject, @unchecked Sendable, FirebaseRemoteConfigServiceProtocol, ConfigCenterProtocol {
    
    public var configSubject = CurrentValueSubject<ConfigObject?, Never>(nil)
    public var configPublisher: AnyPublisher<ConfigObject, Never>
    
    private let stateSubject = CurrentValueSubject<ServiceState, Never>(.idle)
    public let statePublisher: AnyPublisher<ServiceState, Never>
    
    private var coreService: FirebaseCoreServiceProtocol
    private var cancellables: Set<AnyCancellable> = []
    
    
    ///settings
    private var settings: RemoteConfigSettings?
    private var defaultPlist: String = ""
    private var realTimeEnabled: Bool = false
    
    //real-time
    private var configUpdateListenerRegistration: ConfigUpdateListenerRegistration?
    
    required public init(coreService: FirebaseCoreServiceProtocol,
                                     settings: RemoteConfigSettings,
                                     defaultPlist: String,
                                     realTimeEnabled: Bool) {
        self.coreService = coreService
        self.statePublisher = stateSubject.removeDuplicates().eraseToAnyPublisher()
        self.configPublisher = configSubject
            .compactMap({$0})
            .eraseToAnyPublisher()
        self.defaultPlist = defaultPlist
        self.realTimeEnabled = realTimeEnabled
        
        super.init()
    }
}

private extension FirebaseRemoteConfigService {
    func fetchRC() async throws {
        let task = Task.detached(priority: .background) { () in
            let status = try await RemoteConfig.remoteConfig().fetch()
            switch status {
            case .success:
                return ()
            default: throw FirebaseRemoteConfigServiceError(firStatus: status)
            }
        }
        return try await task.value
    }
    
    
    /*
     activate RC to get values
     */
    func activateRC() async throws -> Bool {
        let task = Task.detached(priority: .background) { [weak self] () in
            guard let self else { throw FirebaseRemoteConfigServiceError.unknown }
            let rm = RemoteConfig.remoteConfig()
            let changed = try await rm.activate()
            self.configSubject.send(rm)
            self.stateSubject.send(.ready)
            return changed
        }
        
        return try await task.value
    }
    
    func listenForRealTimeConfig() {
        guard realTimeEnabled else { return }
        
        if configUpdateListenerRegistration != nil {
            configUpdateListenerRegistration?.remove()
        }
        
        configUpdateListenerRegistration = RemoteConfig.remoteConfig().addOnConfigUpdateListener(remoteConfigUpdateCompletion: { [weak self] configUpdate, error in
            guard configUpdate != nil, error == nil else {
                ACCLogger.print(error?.localizedDescription, level: .error)
                return
            }
            Task.detached { [weak self] in
                do {
                    try _ = await self?.activateRC()
                } catch {
                    ACCLogger.print(error.localizedDescription, level: .error)
                }
            }
            
        })
    }
}

extension FirebaseRemoteConfigService: UIApplicationDelegate {
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        //RC must be initialized after FirebaseApp initiation
        coreService.statePublisher
            .filter({$0 == .ready}).prefix(1)
            .sink { [weak self] _ in
                guard let self else { return }
                Task.detached(priority: .background) {
                    let rm = RemoteConfig.remoteConfig()
                    do {
                        if let settings = self.settings { rm.configSettings = settings }
                        if !self.defaultPlist.isEmpty { rm.setDefaults(fromPlist: self.defaultPlist)
                        }
                        
                        try await self.fetchRC()
                        _ = try await self.activateRC()
                        self.listenForRealTimeConfig()
                    }
                    catch {
                        ACCLogger.print(error.localizedDescription, level: .error)
                        self.configSubject.send(rm)
                        self.stateSubject.send(.ready)
                    }
                }
                
            }.store(in: &cancellables)
        
        return true
    }
}

extension RemoteConfig: ConfigObject {
    
    /**
     The currently supported types are:
     
     String
     Boolean
     Number
     JSON
     */
    public subscript<T: Codable>(rcKey: String) -> T? {
        let value = self[rcKey]
        switch T.self {
        case is String.Type:
            return value.stringValue as? T
        case is Bool.Type:
            return value.boolValue as? T
        case is any SignedInteger.Type:
            return value.numberValue.intValue as? T
        case is any UnsignedInteger.Type:
            return value.numberValue.uintValue as? T
        case is Float.Type:
            return value.numberValue.floatValue as? T
        case is Double.Type:
            return value.numberValue.doubleValue as? T
        case is Data.Type:
            return value.dataValue as? T
        default:
            return try? JSONDecoder().decode(T.self, from: value.dataValue)
        }
        
    }
    
    
}
