//
//  PasteboardClient+TestKey.swift
//  CoreKit
//
//  Created by 김민호 on 9/30/24.
//

import Foundation

import Dependencies

extension PasteboardClient: TestDependencyKey {
    public static let previewValue = Self.noop
}

extension PasteboardClient {
    public static let noop = Self(
        changes: { .finished },
        probableWebURL: { nil }
        
    )
}
