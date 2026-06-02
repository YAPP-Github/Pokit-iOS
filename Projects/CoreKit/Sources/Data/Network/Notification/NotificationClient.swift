//
//  NotificationClient.swift
//  CoreKit
//
//  Created by Codex on 2026-04-06.
//

import DependenciesMacros

@DependencyClient
public struct NotificationClient {
    public var 알림_목록_조회: @Sendable (
        _ pageable: BasePageableRequest
    ) async throws -> NotificationListInquiryResponse
    public var 알림_읽음: @Sendable (
        _ notificationId: Int
    ) async throws -> Void
    public var 알림_삭제: @Sendable (
        _ notificationId: Int
    ) async throws -> Void
}
