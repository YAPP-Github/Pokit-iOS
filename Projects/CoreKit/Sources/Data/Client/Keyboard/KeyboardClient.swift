//
//  KeyboardClient.swift
//  CoreKit
//
//  Created by 김민호 on 3/31/25.
//

import Foundation

import DependenciesMacros

@DependencyClient
public struct KeyboardClient: Sendable {
    public var isVisible: @Sendable () async -> AsyncStream<Bool> = { .finished }
}
