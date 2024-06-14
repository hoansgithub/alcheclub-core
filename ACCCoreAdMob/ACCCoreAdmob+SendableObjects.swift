//
//  ACCCoreAdmob+SendableObjects.swift
//  ACCCoreAdMob
//
//  Created by Hoan Nguyen on 22/5/24.
//

import UserMessagingPlatform
import GoogleMobileAds
/*
  Swift 6's concurrency-safety checks are known to be too strict and give false positives in some cases, these extensions are temporarily used for passing through concurrency checks on a specific class/struct and will be removed in future updates when necessary
 */

extension UMPDebugSettings: @unchecked Sendable {}
extension UMPRequestParameters: @unchecked Sendable {}
extension GADInitializationStatus: @unchecked Sendable {}
extension GADNativeAd: @unchecked Sendable {}
