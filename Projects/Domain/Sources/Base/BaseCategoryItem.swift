//
//  BaseCategory.swift
//  Domain
//
//  Created by 김도형 on 7/31/24.
//

import Foundation

import Util

public struct BaseCategoryItem: Identifiable, Equatable, PokitSelectItem, PokitCardItem, Sortable, Shareable {
    public let id: Int
    public let userId: Int
    public let categoryName: String
    public let categoryImage: BaseCategoryImage
    public var contentCount: Int
    public let createdAt: String
    public let openType: BaseOpenType
    public let keywordType: BaseInterestType
    public let userCount: Int
    public let isFavorite: Bool
    
    public init(
        id: Int,
        userId: Int,
        categoryName: String,
        categoryImage: BaseCategoryImage,
        contentCount: Int,
        createdAt: String,
        openType: BaseOpenType,
        keywordType: BaseInterestType,
        userCount: Int,
        isFavorite: Bool
    ) {
        self.id = id
        self.userId = userId
        self.categoryName = categoryName
        self.categoryImage = categoryImage
        self.contentCount = contentCount
        self.createdAt = createdAt
        self.openType = openType
        self.keywordType = keywordType
        self.userCount = userCount
        self.isFavorite = isFavorite
    }
}
