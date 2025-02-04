//
//  BaseContentResponse+Extension.swift
//  Domain
//
//  Created by 김도형 on 8/5/24.
//

import Foundation

import CoreKit
import Util

public extension ContentBaseResponse {
    func toDomain() -> BaseContentItem {
        return .init(
            id: self.contentId,
            categoryName: self.category.categoryName,
            categoryId: self.category.categoryId,
            title: self.title,
            memo: self.memo,
            thumbNail: self.thumbNail,
            data: self.data,
            domain: self.domain,
            createdAt: self.createdAt,
            isRead: self.isRead,
            isFavorite: self.isFavorite,
            keyword: self.keyword
        )
    }
}
