//
//  NotificationItem.swift
//  Domain
//
//  Created by Codex on 2026-04-06.
//

import Foundation

public struct NotificationItem: Identifiable, Equatable {
    public let id: Int
    public let notificationType: String
    public let title: String
    public let body: String
    public let categoryImageUrl: String?
    public var isRead: Bool
    public let navigationType: String
    public let deepLink: String?
    public let createdAt: String

    public init(
        id: Int,
        notificationType: String,
        title: String,
        body: String,
        categoryImageUrl: String?,
        isRead: Bool,
        navigationType: String,
        deepLink: String?,
        createdAt: String
    ) {
        self.id = id
        self.notificationType = notificationType
        self.title = title
        self.body = body
        self.categoryImageUrl = categoryImageUrl
        self.isRead = isRead
        self.navigationType = navigationType
        self.deepLink = deepLink
        self.createdAt = createdAt
    }
}
