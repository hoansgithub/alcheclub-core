//
//  StoreKitManager.swift
//  ACCCoreStoreKit
//
//  Created by HoanNL on 3/7/24.
//

import StoreKit
import ACCCore
import Combine
public enum StoreKitManagerError: Error {
    case failedVerification
    case productNotFound
    case userCancelledPurchase
}

public final class StoreKitManager: @unchecked Sendable {
    public typealias Transaction = StoreKit.Transaction
    public typealias RenewalInfo = StoreKit.Product.SubscriptionInfo.RenewalInfo
    public typealias RenewalState = StoreKit.Product.SubscriptionInfo.RenewalState
    public typealias ProductPurchaseResult = (result: Product.PurchaseResult,transaction: Transaction?)
    
    /// subcribe to get all available products
    private var allProductsSubject = CurrentValueSubject<[Product], Never>([])
    public private(set) var allProductsPub: AnyPublisher<[Product], Never>
    /*
     Subcribe to get purchased products or subcription status except consumable products
     The app should store consumable products persistently right after the purchase
     */
    private var purchasedProductsSubject = CurrentValueSubject<[Product], Never>([])
    public private(set) var purchasedProductsPub: AnyPublisher<[Product], Never>

    private var subGroupStatusSubject = CurrentValueSubject<[String: RenewalState], Never>([:])
    public private(set) var subGroupStatusPub: AnyPublisher<[String: RenewalState], Never>
    
    var updateListenerTask: Task<Void, Error>? = nil
    
    
    init() {
        self.allProductsPub = self.allProductsSubject.eraseToAnyPublisher()
        self.purchasedProductsPub = self.purchasedProductsSubject.eraseToAnyPublisher()
        self.subGroupStatusPub = self.subGroupStatusSubject.eraseToAnyPublisher()
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    func start(productIdentifiers: [String]) async throws {
        //Start a transaction listener as close to app launch as possible so you don't miss any transactions.
        updateListenerTask?.cancel()
        updateListenerTask = listenForTransactions()
        try await requestProducts(identifiers:productIdentifiers)
        await updateCustomerProductStatus()
    }
}
//Product Request

public extension StoreKitManager {
    func requestProducts(identifiers: [String]) async throws {
        let products = try await Product.products(for: identifiers)
        allProductsSubject.send(products)
    }
    
}

//Transactions handling
public extension StoreKitManager {
    
    func restore() async throws {
        try await AppStore.sync()
    }
    
    func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            //Iterate through any transactions that don't come from a direct call to `purchase()`.
            for await result in Transaction.updates {
                do {
                    try Task.checkCancellation()
                    let transaction = try StoreKitManager.checkVerified(result)
                    //Deliver products to the user.
                    await self.updateCustomerProductStatus()

                    //Always finish a transaction.
                    await transaction.finish()
                } catch {
                    //StoreKit has a transaction that fails verification. Don't deliver content to the user.
                    ACCLogger.print(error.localizedDescription, level: .error)
                }
            }
        }
    }
    
    func purchase(productID: String, accountToken: UUID? = nil) async throws -> ProductPurchaseResult {
        guard let product = allProductsSubject.value.first(where: {$0.id == productID}) else {
            throw StoreKitManagerError.productNotFound
        }
        
        var options: Set<Product.PurchaseOption> = []
        if let accountToken = accountToken {
            options.insert(.appAccountToken(accountToken))
        }
        let result = try await product.purchase(options: options)

        switch result {
        case .success(let verification):
            //Check whether the transaction is verified. If it isn't,
            //this function rethrows the verification error.
            let transaction = try StoreKitManager.checkVerified(verification)
            
            //Always finish a transaction.
            await transaction.finish()
            
            //The transaction is verified. Deliver content to the user.
            await updateCustomerProductStatus()
            return (result, transaction)
        case .userCancelled:
            throw StoreKitManagerError.userCancelledPurchase
        default:
            return (result, nil)
        }
    }
    
    func updateCustomerProductStatus() async {
        var verifiedProducts: [Product] = []
        var verifiedSubscriptionGroupStatus: [String: RenewalState] = [:]
        
        //Iterate through all of the user's purchased products.
        for await result in Transaction.currentEntitlements {
            do {
                //Check whether the transaction is verified. If it isn’t, catch `failedVerification` error.
                let transaction = try StoreKitManager.checkVerified(result)
                if transaction.purchaseDate != transaction.originalPurchaseDate {
                    debugPrint("RENEW")
                }
                
                if let storedProduct = allProductsSubject.value.first(where: { $0.id == transaction.productID }) {
                    verifiedProducts.append(storedProduct)
                }
            } catch {
                ACCLogger.print(error.localizedDescription, level: .error)
            }
        }

        self.purchasedProductsSubject.send(verifiedProducts)

        //Check the `subscriptionGroupStatus` to learn the auto-renewable subscription state to determine whether the customer
        //is new (never subscribed), active, or inactive (expired subscription).Once this app has only one subscription
        //group, products in the subscriptions array all belong to the same group. The statuses that
        //`product.subscription.status` returns apply to the entire subscription group.
        
        for prod in verifiedProducts.filter({$0.type == .autoRenewable}) {
            guard let groupID = prod.subscription?.subscriptionGroupID,
                  let status = try? await prod.subscription?.status.first?.state else { return }
            verifiedSubscriptionGroupStatus[groupID] = status
        }
        subGroupStatusSubject.send(verifiedSubscriptionGroupStatus)
    }
}

//Verification
@available(iOS 15.0, *)
public extension StoreKitManager {
    static func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        //Check whether the JWS passes StoreKit verification.
        switch result {
        case .unverified:
            //StoreKit parses the JWS, but it fails verification.
            throw StoreKitManagerError.failedVerification
        case .verified(let safe):
            //The result is verified. Return the unwrapped value.
            return safe
        }
    }
    
}
