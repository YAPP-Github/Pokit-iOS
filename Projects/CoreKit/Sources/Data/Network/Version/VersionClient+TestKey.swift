//
//  VersionClient+TestKey.swift
//  CoreKit
//
//  Created by 김민호 on 9/30/24.
//

import Dependencies

extension VersionClient: TestDependencyKey {
    public static let previewValue: Self = {
        Self(
            버전체크: { .mock }
        )
    }()
}
