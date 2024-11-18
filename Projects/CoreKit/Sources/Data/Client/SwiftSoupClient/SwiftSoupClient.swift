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
    public var parseOGTitle: @Sendable (
        _ url: URL
    ) async throws -> String? = { _ in nil }
    
    public var parseOGImageURL: @Sendable (
        _ url: URL
    ) async throws -> String? = { _ in nil }
}
