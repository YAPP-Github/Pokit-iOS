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
                contentCount: self.category.contentCount
            ),
            contents: self.contents.toDomain()
        )
    }
}
