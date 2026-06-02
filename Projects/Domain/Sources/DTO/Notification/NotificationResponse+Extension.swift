//
//  NotificationResponse+Extension.swift
//  Domain
//
//  Created by Codex on 2026-04-06.
//

import Foundation

import CoreKit

public extension NotificationResponse {
    func toDomain() -> NotificationItem {
        .init(
            id: self.id,
            notificationType: self.notificationType,
            title: self.title,
            body: self.body,
            categoryImageUrl: self.categoryImageUrl,
            isRead: self.isRead,
            navigationType: self.navigationType,
            deepLink: self.deepLink,
            createdAt: self.createdAt
        )
    }
}
