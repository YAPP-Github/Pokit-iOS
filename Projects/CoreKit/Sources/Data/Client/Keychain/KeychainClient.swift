//
//  KeychainClient.swift
//  Data
//
//  Created by 김민호 on 7/30/24.
//

import Foundation

import DependenciesMacros

public enum KeychainKey: String {
    case accessToken
    case refreshToken
    case serverRefresh
}

@DependencyClient
public struct KeychainClient {
    public var save: @Sendable (KeychainKey, String) -> Void
    public var read: @Sendable (KeychainKey) -> (String?) = { _ in nil }
    public var delete: @Sendable (KeychainKey) -> Void
}

