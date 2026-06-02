//
//  NotificationClient+TestKey.swift
//  CoreKit
//
//  Created by Codex on 2026-04-06.
//

import Dependencies

extension NotificationClient: TestDependencyKey {
    public static let previewValue: Self = {
        Self(
            알림_목록_조회: { _ in .mock },
            알림_읽음: { _ in },
            알림_삭제: { _ in }
        )
    }()
}
