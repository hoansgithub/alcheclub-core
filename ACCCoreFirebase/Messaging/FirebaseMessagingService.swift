//
//  FirebaseMessagingService.swift
//  ACCCoreFirebase
//
//  Created by HoanNL on 23/04/2024.
//

import ACCCore
import Combine
import FirebaseMessaging

public enum FirebaseMessagingServiceError: Error {
    case applicationNotFound
}

public final class FirebaseMessagingService: NSObject, @unchecked Sendable, FirebaseMessagingServiceProtocol {
    
    //publishers
    private let stateSubject = CurrentValueSubject<ServiceState, Never>(.idle)
    public let statePublisher: AnyPublisher<ServiceState, Never>
    private let tokenSubject = CurrentValueSubject<String?, Never>(nil)
    public let tokenPublisher: AnyPublisher<String, Never>
    private let authStatusSubject = CurrentValueSubject<UNAuthorizationStatus?, Never>(nil)
    public let authStatusPublisher: AnyPublisher<UNAuthorizationStatus, Never>
    
    private weak var application: UIApplication?
    private var coreService: FirebaseCoreServiceProtocol
    private var cancellables: Set<AnyCancellable> = []
    private var registrationCancellable: AnyCancellable?
    private var authOptions: UNAuthorizationOptions
    private var presentationOptions: UNNotificationPresentationOptions
    nonisolated required public init(coreService: FirebaseCoreServiceProtocol,
                                     authOptions: UNAuthorizationOptions,
                                     presentationOptions: UNNotificationPresentationOptions) {
        self.coreService = coreService
        self.authOptions = authOptions
        self.presentationOptions = presentationOptions
        self.statePublisher = stateSubject.removeDuplicates().eraseToAnyPublisher()
        self.authStatusPublisher = authStatusSubject
            .compactMap({$0})
            .removeDuplicates()
            .eraseToAnyPublisher()
        self.tokenPublisher = tokenSubject
            .compactMap({$0})
            .removeDuplicates()
            .eraseToAnyPublisher()
        super.init()
    }
    
    public func registerForRemoteNotifications() async throws -> Bool {
        guard let application = self.application else {
            throw FirebaseMessagingServiceError.applicationNotFound
        }
        
        await application.registerForRemoteNotifications()
        
        return try await UNUserNotificationCenter.current().requestAuthorization(options: authOptions)
    }
    
    public func getPermissionStatus() async -> UNAuthorizationStatus {
        return await withCheckedContinuation { cont in
            let current = UNUserNotificationCenter.current()
            current.getNotificationSettings { settings in
                cont.resume(returning: settings.authorizationStatus)
            }
        }
    }
}

extension FirebaseMessagingService: UIApplicationDelegate {
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        self.application = application
        Task {
            try await startService()
        }
        return true
    }
}

private extension FirebaseMessagingService {
    
    func startService() async throws {
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        _ = await waitForCoreServiceAvailability()
        stateSubject.send(.ready)
    }
    
    func waitForCoreServiceAvailability() async {
        return await withCheckedContinuation { cont in
            registrationCancellable?.cancel()
            registrationCancellable = coreService.statePublisher
                .filter({$0 == .ready}).prefix(1)
                .sink(receiveValue: { _ in
                    cont.resume(returning: ())
                })
        }
    }
    
    func broadcastPermissionStatus() {
        Task {
            let status = await getPermissionStatus()
            authStatusSubject.send(status)
        }
    }
}

///UNUserNotificationCenterDelegate
extension FirebaseMessagingService: UNUserNotificationCenterDelegate {
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(presentationOptions)
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    public func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        completionHandler(.newData)
    }
}

///MessagingDelegate
extension FirebaseMessagingService: MessagingDelegate {
    
    public func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        ACCLogger.print("FirebaseMessaging registration token: \(String(describing: fcmToken))")
        // Note: This callback is fired at each app startup and whenever a new token is generated.
        // If necessary, send token to application server.
        tokenSubject.send(fcmToken)
        broadcastPermissionStatus()
    }
    
}
