//
//  ContentDetailResponse+Extension.swift
//  Domain
//
//  Created by 김도형 on 8/5/24.
//

import Foundation

import CoreKit
import Util

public extension ContentDetailResponse {
    func toDomain() -> BaseContentDetail {
        return .init(
            id: self.contentId,
            category: BaseCategoryInfo(
                categoryId: self.category.categoryId,
                categoryName: self.category.categoryName
            ),
            title: self.title,
            data: self.data,
            memo: self.memo,
            createdAt: DateFormatter.stringToDate(string: self.createdAt),
            favorites: self.favorites,
            alertYn: BaseContentDetail.RemindState(rawValue: self.alertYn) ?? .no)
    }
}
