//
//  PastboardClient.swift
//  CoreKit
//
//  Created by 김민호 on 8/2/24.
//

import Foundation
import Dependencies

extension DependencyValues {
    public var pasteboard: PasteboardClient {
        get { self[PasteboardClient.self] }
        set { self[PasteboardClient.self] = newValue }
    }
}

public struct PasteboardClient: Sendable {
    public var changes: @Sendable () -> AsyncStream<Void>
    public var probableWebURL: @Sendable () async throws -> URL?
}
