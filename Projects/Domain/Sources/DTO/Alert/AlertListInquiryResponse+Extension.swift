//
//  AlertListInquiryResponse+Extension.swift
//  Domain
//
//  Created by 김민호 on 8/17/24.
//

import Foundation

import CoreKit

public extension AlertListInquiryResponse {
    func toDomain() -> AlertListInquiry {
        return .init(
            data: self.data.map { $0.toDomain() },
            page: self.page,
            size: self.size,
            sort: self.sort.map { $0.toDomain() },
            hasNext: self.hasNext
        )
    }
}

public extension AlertItemInquiryResponse {
    func toDomain() -> AlertItem {
        return .init(
            id: self.id,
            userId: self.userId,
            contentId: self.contentId,
            thumbNail: self.thumbNail,
            title: self.title,
            body: self.body,
            createdAt: self.createdAt
        )
    }
}
