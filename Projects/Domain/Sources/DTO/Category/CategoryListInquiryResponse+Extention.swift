//
//  CategoryListInquiryResponse+Extention.swift
//  Domain
//
//  Created by 김도형 on 8/4/24.
//

import Foundation

import CoreKit
import Util

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
    func toDomain() -> BaseCategoryItem {
        return .init(
            id: self.categoryId,
            userId: self.userId,
            categoryName: self.categoryName,
            categoryImage: self.categoryImage.toDomain(),
            contentCount: self.contentCount,
            createdAt: self.createdAt,
            openType: BaseOpenType(rawValue: self.openType) ?? .비공개,
            keywordType: BaseInterestType(rawValue: self.keywordType.slashConvertUnderBar) ?? .default,
            userCount: self.userCount
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
