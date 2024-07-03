//
//  StoreProductManager.swift
//  ACCCoreStoreKit
//
//  Created by HoanNL on 3/7/24.
//

import StoreKit

public enum StoreProductManagerError: Error {
    case failedVerification
}

public final class StoreProductManager: @unchecked Sendable {
    public typealias Transaction = StoreKit.Transaction
    public typealias RenewalInfo = StoreKit.Product.SubscriptionInfo.RenewalInfo
    public typealias RenewalState = StoreKit.Product.SubscriptionInfo.RenewalState
    public typealias ProductPurchaseResult = (result: Product.PurchaseResult,transaction: Transaction?)
    
    /// subcribe to get all available products
    @Published private(set) var allProducts: [Product] = []
    
    /*
     Subcribe to get purchased products or subcription status except consumable products
     The app should store consumable products persistently right after the purchase
     */
    @Published private(set) var purchasedProducts: [Product] = []

    @Published private(set) var subscriptionGroupStatus: [String: RenewalState] = [:]
    
    var updateListenerTask: Task<Void, Error>? = nil
    
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

public extension StoreProductManager {
    func requestProducts(identifiers: [String]) async throws {
        let products = try await Product.products(for: identifiers)
        allProducts = products
    }
    
    func getProduct(id: String) -> Product? {
        return allProducts.first(where: {$0.id == id})
    }
}

//Transactions handling
public extension StoreProductManager {
    
    func restore() async throws {
        try await AppStore.sync()
    }
    
    func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            //Iterate through any transactions that don't come from a direct call to `purchase()`.
            for await result in Transaction.updates {
                do {
                    try Task.checkCancellation()
                    let transaction = try StoreProductManager.checkVerified(result)
                    //Deliver products to the user.
                    await self.updateCustomerProductStatus()

                    //Always finish a transaction.
                    await transaction.finish()
                } catch {
                    //StoreKit has a transaction that fails verification. Don't deliver content to the user.
                    debugPrint("\(self) \(#function): \(error.localizedDescription)")
                }
            }
        }
    }
    
    func updateCustomerProductStatus() async {
        var verifiedProducts: [Product] = []
        var verifiedSubscriptionGroupStatus: [String: RenewalState] = [:]
        
        //Iterate through all of the user's purchased products.
        for await result in Transaction.currentEntitlements {
            do {
                //Check whether the transaction is verified. If it isn’t, catch `failedVerification` error.
                let transaction = try StoreProductManager.checkVerified(result)
                if transaction.purchaseDate != transaction.originalPurchaseDate {
                    debugPrint("RENEW")
                }
                
                if let storedProduct = allProducts.first(where: { $0.id == transaction.productID }) {
                    verifiedProducts.append(storedProduct)
                }
            } catch {
                debugPrint("\(self) \(#function): \(error.localizedDescription)")
            }
        }

        self.purchasedProducts = verifiedProducts

        //Check the `subscriptionGroupStatus` to learn the auto-renewable subscription state to determine whether the customer
        //is new (never subscribed), active, or inactive (expired subscription).Once this app has only one subscription
        //group, products in the subscriptions array all belong to the same group. The statuses that
        //`product.subscription.status` returns apply to the entire subscription group.
        
        for prod in verifiedProducts.filter({$0.type == .autoRenewable}) {
            guard let groupID = prod.subscription?.subscriptionGroupID,
                  let status = try? await prod.subscription?.status.first?.state else { return }
            verifiedSubscriptionGroupStatus[groupID] = status
        }
        self.subscriptionGroupStatus = verifiedSubscriptionGroupStatus
    }
}

//Verification
@available(iOS 15.0, *)
public extension StoreProductManager {
    static func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        //Check whether the JWS passes StoreKit verification.
        switch result {
        case .unverified:
            //StoreKit parses the JWS, but it fails verification.
            throw StoreProductManagerError.failedVerification
        case .verified(let safe):
            //The result is verified. Return the unwrapped value.
            return safe
        }
    }
    
}
