//
//  NotificationListInquiryResponse.swift
//  CoreKit
//
//  Created by Codex on 2026-04-06.
//

import Foundation

public struct NotificationListInquiryResponse: Decodable {
    public let data: [NotificationResponse]
    public let page: Int
    public let size: Int
    public let sort: [ItemInquirySortResponse]
    public let hasNext: Bool
}

extension NotificationListInquiryResponse {
    public static var mock: Self = .init(
        data: [
            .mock(id: 1),
            .mock(id: 2)
        ],
        page: 0,
        size: 10,
        sort: [
            ItemInquirySortResponse(
                direction: "DESC",
                nullHandling: "NATIVE",
                ascending: false,
                property: "createdAt",
                ignoreCase: false
            )
        ],
        hasNext: false
    )
}
