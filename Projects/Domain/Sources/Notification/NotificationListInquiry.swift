//
//  NotificationListInquiry.swift
//  Domain
//
//  Created by Codex on 2026-04-06.
//

import Foundation

import Util

public struct NotificationListInquiry: Equatable {
    public var data: [NotificationItem]
    public let page: Int
    public let size: Int
    public let sort: [BaseItemInquirySort]
    public let hasNext: Bool

    public init(
        data: [NotificationItem],
        page: Int,
        size: Int,
        sort: [BaseItemInquirySort],
        hasNext: Bool
    ) {
        self.data = data
        self.page = page
        self.size = size
        self.sort = sort
        self.hasNext = hasNext
    }
}
