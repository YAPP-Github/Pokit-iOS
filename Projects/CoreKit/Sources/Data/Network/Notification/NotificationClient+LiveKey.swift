//
//  NotificationClient+LiveKey.swift
//  CoreKit
//
//  Created by Codex on 2026-04-06.
//

import Dependencies
import Moya

extension NotificationClient: DependencyKey {
    public static let liveValue: Self = {
        let provider = MoyaProvider<NotificationEndpoint>.build()

        return Self(
            알림_목록_조회: { pageable in
                try await provider.request(.알림_목록_조회(model: pageable))
            },
            알림_읽음: { notificationId in
                try await provider.requestNoBody(.알림_읽음(notificationId: notificationId))
            },
            알림_삭제: { notificationId in
                try await provider.requestNoBody(.알림_삭제(notificationId: notificationId))
            }
        )
    }()
}
