//
//  SharedCategoryResponse+Extension.swift
//  Domain
//
//  Created by 김도형 on 8/22/24.
//

import Foundation

import CoreKit

public extension SharedCategoryResponse {
    func toDomain() -> CategorySharing.SharedCategory {
        return .init(
            category: .init(
                categoryId: self.category.categoryId,
                categoryName: self.category.categoryName,
                contentCount: self.category.contentCount,
                categoryImageId: self.category.categoryImageId,
                categoryImageUrl: self.category.categoryImageUrl
            ),
            contentList: self.contents.toDomain(categoryName: self.category.categoryName)
        )
    }
}

public extension SharedCategoryResponse.Content {
    func toDomain(categoryName: String) -> CategorySharing.Content {
        return .init(
            id: self.contentId,
            data: self.data,
            domain: self.domain,
            title: self.title,
            memo: self.memo,
            thumbNail: self.thumbNail,
            createdAt: self.createdAt,
            categoryName: categoryName
        )
    }
}

public extension SharedCategoryResponse.ContentListInquiry {
    func toDomain(categoryName: String) -> CategorySharing.ContentListInquiry {
        return .init(
            data: self.data.map { $0.toDomain(categoryName: categoryName) },
            page: self.page,
            size: self.size,
            sort: self.sort.map { $0.toDomain() },
            hasNext: self.hasNext
        )
    }
}
