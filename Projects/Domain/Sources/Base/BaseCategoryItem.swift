//
//  BaseCategory.swift
//  Domain
//
//  Created by 김도형 on 7/31/24.
//

import Foundation

import Util

public struct BaseCategoryItem: Identifiable, Equatable, PokitSelectItem, PokitCardItem {
    public let id: Int
    public let userId: Int
    public let categoryName: String
    public let categoryImage: BaseCategoryImage
    public var contentCount: Int
    public let createdAt: String
    
    public init(
        id: Int,
        userId: Int,
        categoryName: String,
        categoryImage: BaseCategoryImage,
        contentCount: Int,
        createdAt: String
    ) {
        self.id = id
        self.userId = userId
        self.categoryName = categoryName
        self.categoryImage = categoryImage
        self.contentCount = contentCount
        self.createdAt = createdAt
    }
}
