//
//  NotificationResponse.swift
//  CoreKit
//
//  Created by Codex on 2026-04-06.
//

import Foundation

import Util

public struct NotificationResponse: Decodable {
    public let id: Int
    public let notificationType: String
    public let title: String
    public let body: String
    public let categoryImageUrl: String?
    public let isRead: Bool
    public let navigationType: String
    public let deepLink: String?
    public let createdAt: String
}

extension NotificationResponse {
    public static func mock(id: Int) -> Self {
        .init(
            id: id,
            notificationType: "LINK_ADDED",
            title: "'뜨개질' 포킷에 링크가 추가되었어요",
            body: "OO님이 추가한 링크를 지금 확인해보세요",
            categoryImageUrl: Constants.mockImageUrl,
            isRead: false,
            navigationType: "CONTENT_DETAIL",
            deepLink: "pokit://shared?categoryId=42&contentId=123",
            createdAt: "2026-02-18T00:00:00Z"
        )
    }
}
