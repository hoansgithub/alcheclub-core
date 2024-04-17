//
//  AnyPublisher+Sendable.swift
//  ACCCore
//
//  Created by HoanNL on 17/04/2024.
//

import Combine

/*  Generic struct 'AnyPublisher'
 does not conform to the 'Sendable'
 protocol (Combine.AnyPublisher) by default */
extension AnyPublisher: @unchecked Sendable {}
