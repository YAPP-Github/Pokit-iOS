//
//  PasteboardClient.swift
//  CoreKit
//
//  Created by 김민호 on 8/2/24.
//

import Foundation
import DependenciesMacros

@DependencyClient
public struct PasteboardClient: Sendable {
    public var changes: @Sendable () -> AsyncStream<Void> = { .finished }
    public var probableWebURL: @Sendable () async throws -> URL?
}
