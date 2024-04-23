//
//  FirebaseMessagingService.swift
//  ACCCoreFirebase
//
//  Created by HoanNL on 23/04/2024.
//

import ACCCore
import Combine
import FirebaseMessaging
public final class FirebaseMessagingService: NSObject, @unchecked Sendable, FirebaseMessagingServiceProtocol {
    
    private let stateSubject = CurrentValueSubject<ServiceState, Never>(.idle)
    public let statePublisher: AnyPublisher<ServiceState, Never>
    private let authStatusSubject = CurrentValueSubject<UNAuthorizationStatus?, Never>(nil)
    public let authStatusPublisher: AnyPublisher<UNAuthorizationStatus, Never>
    
    private var coreService: FirebaseCoreServiceProtocol
    private var cancellables: Set<AnyCancellable> = []
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
        super.init()
    }
    
    
}

extension FirebaseMessagingService: UIApplicationDelegate {
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        //Service must be initialized after FirebaseApp initiation
        coreService.statePublisher
            .filter({$0 == .ready}).prefix(1)
            .sink { [weak self] _ in
                guard let self else { return }
                self.registerForRemoteNotifications(application: application)
            }.store(in: &cancellables)
        return true
    }
}

private extension FirebaseMessagingService {
    @MainActor func registerForRemoteNotifications(application: UIApplication) {
        UNUserNotificationCenter.current().delegate = self
        
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
        )
        
        application.registerForRemoteNotifications()
        Messaging.messaging().delegate = self
    }
    
    func updatePermissionStatus() {
        let current = UNUserNotificationCenter.current()
        current.getNotificationSettings {[weak self] settings in
            self?.authStatusSubject.send(settings.authorizationStatus)
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
        ACCLogger.print("Firebase registration token: \(String(describing: fcmToken))")
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    
}
