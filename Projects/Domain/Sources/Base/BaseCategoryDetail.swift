//
//  BaseCategoryDetail.swift
//  Domain
//
//  Created by 김도형 on 8/8/24.
//

import Foundation

import CoreKit

public struct BaseCategoryDetail: Equatable {
    public let categoryId: Int
    public let categoryName: String
    public let categoryImage: BaseCategoryImage
    
    public init(
        categoryId: Int,
        categoryName: String,
        categoryImage: BaseCategoryImage
    ) {
        self.categoryId = categoryId
        self.categoryName = categoryName
        self.categoryImage = categoryImage
    }
}
