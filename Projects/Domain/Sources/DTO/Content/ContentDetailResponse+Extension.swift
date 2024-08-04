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
    func toDomain() -> LinkDetail.Content {
        return .init(
            id: self.contentId,
            categoryName: self.categoryName,
            categoryId: self.categoryId,
            title: self.title,
            thumbNail: self.thumbNail,
            data: self.data,
            memo: self.memo,
            createdAt: DateFormatter.stringToDate(string: self.createdAt),
            favorites: self.favorites,
            alertYn: BaseContent.RemindState(rawValue: self.alertYn) ?? .no)
    }
}
