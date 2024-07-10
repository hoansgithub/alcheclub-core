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
import ACCCoreUtilities
final class TeslaService: NSObject, @unchecked Sendable, ACCService {
    
    struct Routes {
        var authBuilder: URLRequestBuilder {
            return URLRequestBuilder(baseURL: URL(string: "https://www.fitbit.com")!)
        }
        
        var apiBuilder: URLRequestBuilder {
            return URLRequestBuilder(baseURL: URL(string: "https://api.fitbit.com/")!)
        }
        
        func requestOAuth() -> URLRequest {
            return authBuilder.get("oauth2/authorize").setValue("accept", forHeader: "application/json")
                .queryItems([
                    "client_id": "22C29R",
                    "response_type": "code",
                    "scope": "profile",
                    "redirect_uri": "fitracker://auth",
                    "expires_in": "600"
                ])
        }
        
        func refresh(refreshToken: String, clientID: String) -> URLRequest {
            return apiBuilder.post("oauth2/token")
                .setValue("Basic MjJDMjlSOjNlMWY1OTdhZjRjZTY2MTRhNjExM2UyOWYwM2MyYjc4", forHeader: "authorization")
                .body(params: RefreshTokenParams(grant_type: "refresh_token", refresh_token: refreshToken, client_id: clientID).bodyParams)
        }
        
        func exchangeForToken(code: String) -> URLRequest {
            return apiBuilder.post("oauth2/token")
                .setValue("Basic MjJDMjlSOjNlMWY1OTdhZjRjZTY2MTRhNjExM2UyOWYwM2MyYjc4", forHeader: "authorization")
                .body(params: GetTokenParams(code: code).bodyParams)
        }
        
        func getProfile(token: String, userID: String) -> URLRequest {
            return apiBuilder.post(String(format: "1/user/%@/profile.json", userID))
                .setValue("Bearer \(token)", forHeader: "authorization")
        }
    }
    
//    @UserDefaultProp(key: (Bundle.main.bundleIdentifier ?? "") + ".TeslaService.code",
//                     defaultValue: nil)
//    var code: String?
    
    
    @CodableUserDefaultProp(key: "", defaultValue: nil)
    private var tokenResponse: TokenResponse? {
        didSet {
            tokenPublisher.send(tokenResponse)
        }
    }
    
    public lazy var tokenPublisher = CurrentValueSubject<TokenResponse?, Never>(tokenResponse)
    
    let routes: Routes
    let networkService: AsyncHTTPNetworkService
    static let shared = TeslaService()
    private override init() {
        routes = Routes()
        networkService = AsyncHTTPNetworkService()
        super.init()
        let wSelf = { [weak self] in
            return self
        }
        
        networkService.errorHandlers = [wSelf()]
    }
    
    @MainActor func requestOAuth() async -> URL? {
        if let url = routes.requestOAuth().url, UIApplication.shared.canOpenURL(url) {
            await UIApplication.shared.open(url)
            return url
        }
        return nil
    }
    
    func exchangeForToken(code: String) async throws -> TokenResponse {
        let req = routes.exchangeForToken(code: code)
        return try await networkService.requestObject(req)
    }
    
    func getProfile() async throws -> FBUserProfile {
        let token = tokenResponse?.access_token ?? ""
        let uid = tokenResponse?.user_id ?? ""
        let req = routes.getProfile(token: token, userID: uid)
        return try await networkService.requestObject(req)
    }
    
    func refresh(refreshToken: String, clientID: String) async throws -> TokenResponse {
        let req = routes.refresh(refreshToken: refreshToken, clientID: clientID)
        return try await networkService.requestObject(req)
    }
    
    func logOut() {
        tokenResponse = nil
    }
}

private extension TeslaService {
    func handleTokenTask(result: Result<TokenResponse, Error>) {
        //exchange for token
        
            switch result {
            case .success(let success):
                tokenResponse = success
                ACCLogger.print(tokenResponse)
            case .failure(let failure):
                
                if let err = failure as? NetworkError {
                    switch err {
                    case .non200StatusCode(let stt, let data) :
                        do {
                            let obj = try JSONDecoder().decode(RequestErrors.self, from: data!)
                            ACCLogger.print(obj, level: .error)
                        } catch {
                            ACCLogger.print(error, level: .error)
                        }
                        
                    default: break
                    }
                }
            }
        
    }
}

//URL Scheme handler

extension TeslaService: UIWindowSceneDelegate {
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let firstUrl = URLContexts.first?.url else {
            return
        }
        debugPrint(firstUrl.pathComponents.first)
        if let code = firstUrl["code"] {
            let task = Task {
                return try await exchangeForToken(code: code)
            }
            
            Task {
                let result = await task.result
                handleTokenTask(result: result)
            }
            
        }
        
        
    }
}

extension TeslaService: AsyncNetworkErrorHandler {
    func canHandle(_ error: Error) -> Bool {
        if let err = error as? NetworkError, case .non200StatusCode(let sttCode,let data) = err, sttCode == 401 {
            return true
        }
        return false
    }
    
    func handle(_ error: Error) async throws {
        if let err = error as? NetworkError, case .non200StatusCode(let sttCode,let data) = err, sttCode == 401, let refreshToken = tokenResponse?.refresh_token {
            let refreshTask = Task {
                return try await refresh(refreshToken: refreshToken, clientID: "22C29R")
            }
            Task {
                let refreshResult = await refreshTask.result
                handleTokenTask(result: refreshResult)
            }
        } else {
            throw error
        }
        
        
    }
    
    
}
