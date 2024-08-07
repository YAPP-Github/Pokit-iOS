//
//  CategoryListInquiryResponse+Extention.swift
//  Domain
//
//  Created by 김도형 on 8/4/24.
//

import Foundation

import CoreKit

public extension CategoryListInquiryResponse {
    func toDomain() -> BaseCategoryListInquiry {
        return .init(
            data: self.data.map { $0.toDomain() },
            page: self.page,
            size: self.size,
            sort: self.sort.map { $0.toDomain() },
            hasNext: self.hasNext
        )
    }
}

public extension CategoryItemInquiryResponse {
    func toDomain() -> BaseCategory {
        return .init(
            id: self.categoryId,
            userId: self.userId,
            categoryName: self.categoryName,
            categoryImage: self.categoryImage.toDomain(),
            contentCount: self.contentCount
        )
    }
}

public extension ItemInquirySortResponse {
    func toDomain() -> BaseItemInquirySort {
        return .init(
            direction: self.direction,
            nullHandling: self.nullHandling,
            ascending: self.ascending,
            property: self.property,
            ignoreCase: self.ignoreCase
        )
    }
}
