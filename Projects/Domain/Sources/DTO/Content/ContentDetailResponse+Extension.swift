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
    func toDomain() -> ContentDetail.Content {
        return .init(
            id: self.contentId,
            categoryId: self.categoryId,
            title: self.title,
            data: self.data,
            memo: self.memo,
            createdAt: DateFormatter.stringToDate(string: self.createdAt),
            favorites: self.favorites,
            alertYn: ContentDetail.Content.RemindState(rawValue: self.alertYn) ?? .no)
    }
}
