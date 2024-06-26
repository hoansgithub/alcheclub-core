//
//  TeslaService.swift
//  Example-iOS
//
//  Created by HoanNL on 26/6/24.
//

import Foundation
import ACCCore
import ACCCoreNetworking
import UIKit
import Combine
final class TeslaService: NSObject, ServiceProtocol {
    var statePublisher: AnyPublisher<ServiceState, Never>
    
    struct Routes {
        var authBuilder: URLRequestBuilder {
            return URLRequestBuilder(baseURL: URL(string: "https://www.fitbit.com")!)
        }
        
        func requestOAuth() -> URLRequest {
            return authBuilder.get("oauth2/authorize").setValue("accept", forHeader: "application/json")
                .setValue("authorization", forHeader: "Basic Y2xpZW50X2lkOiAzZTFmNTk3YWY0Y2U2NjE0YTYxMTNlMjlmMDNjMmI3OA==").queryItems([
                    "client_id": "22C29R",
                    "response_type": "token",
                    "scope": "profile",
                    "redirect_uri": "fitracker://auth",
                    "expires_in": "600"
                ])
        }
    }
    
    var routes: Routes
    var networkService: AsyncHTTPNetworkService
    static let shared = TeslaService()
    private override init() {
        routes = Routes()
        networkService = AsyncHTTPNetworkService()
        statePublisher = PassthroughSubject<ServiceState, Never>().eraseToAnyPublisher()
        super.init()
    }
    
    @MainActor func requestOAuth() async -> URL? {
        if let url = routes.requestOAuth().url, UIApplication.shared.canOpenURL(url) {
            await UIApplication.shared.open(url)
            return url
        }
        return nil
    }
}

//URL Scheme handler
extension TeslaService: UIApplicationDelegate {
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        debugPrint(url)
        
        // Determine who sent the URL.
        let sendingAppID = options[.sourceApplication]
        print("source application = \(sendingAppID ?? "Unknown")")
        
        // Process the URL.
        guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true),
              let path = components.path,
              let params = components.queryItems else {
            print("Invalid URL or album path missing")
            return false
        }
        
        
        
        return true
    }
}

extension TeslaService: UIWindowSceneDelegate {
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let firstUrl = URLContexts.first?.url else {
            return
        }
        
        print(firstUrl.absoluteString)
    }
}
