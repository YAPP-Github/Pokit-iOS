//
//  KeyboardClient+TestKey.swift
//  CoreKit
//
//  Created by 김민호 on 3/31/25.
//

import Foundation

import Dependencies

extension KeyboardClient: TestDependencyKey {
    public static let previewValue = Self.noop
}

extension KeyboardClient {
    public static let noop = Self(
        isVisible: { .finished }
    )
}
