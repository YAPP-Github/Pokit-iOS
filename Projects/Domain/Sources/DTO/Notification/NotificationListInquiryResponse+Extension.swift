//
//  NotificationListInquiryResponse+Extension.swift
//  Domain
//
//  Created by Codex on 2026-04-06.
//

import Foundation

import CoreKit

public extension NotificationListInquiryResponse {
    func toDomain() -> NotificationListInquiry {
        .init(
            data: self.data.map { $0.toDomain() },
            page: self.page,
            size: self.size,
            sort: self.sort.map { $0.toDomain() },
            hasNext: self.hasNext
        )
    }
}
