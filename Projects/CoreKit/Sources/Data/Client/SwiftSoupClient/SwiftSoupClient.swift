//
//  SwiftSoupClient.swift
//  CoreKit
//
//  Created by 김도형 on 7/19/24.
//

import Foundation

import DependenciesMacros

@DependencyClient
public struct SwiftSoupClient {
    public var parseOGTitleAndImage: @Sendable (
        _ url: URL,
        _ completion: @Sendable () async -> Void
    ) async -> (String?, String?) = { _, _ in (nil , nil) }
}
