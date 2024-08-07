//
//  ContentListInquiryResponse+Extension.swift
//  Domain
//
//  Created by 김도형 on 8/5/24.
//

import Foundation

import CoreKit

public extension ContentListInquiryResponse {
    func toDomain() -> BaseContentListInquiry {
        return .init(
            data: self.data.map { $0.toDomain() },
            page: self.page,
            size: self.size,
            sort: self.sort.map { $0.toDomain() },
            hasNext: self.hasNext
        )
    }
}
