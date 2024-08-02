//
//  PastboardClient+TestKey.swift
//  CoreKit
//
//  Created by 김민호 on 8/2/24.
//

import Foundation
import Dependencies
import XCTestDynamicOverlay

extension PasteboardClient: TestDependencyKey {
    public static let previewValue = Self.noop
    
    public static let testValue = Self(
        changes: unimplemented("\(Self.self).changes"),
        probableWebURL: unimplemented("\(Self.self).probableWebURL")
    )
}

extension PasteboardClient {
    public static let noop = Self(
        changes: { .finished },
        probableWebURL: { nil }
    )
}
