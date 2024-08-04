//
//  CategoryItemMock.swift
//  FeatureCategoryDetail
//
//  Created by 김민호 on 7/30/24.
//

import Foundation

import Util

public struct CategoryItemMock: PokitSelectItem, Identifiable {
    public var categoryName: String
    
    public var contentCount: Int
    
    public var id: UUID = .init()
    
    public init(
        categoryType: String,
        contentSize: Int
    ) {
        self.categoryName = categoryType
        self.contentCount = contentSize
    }
    
    static var addLinkMock: [CategoryItemMock] {
        return [
            .init(categoryType: "미분류", contentSize: 15),
            .init(categoryType: "포킷명", contentSize: 15),
            .init(categoryType: "포킷명", contentSize: 15),
            .init(categoryType: "포킷명", contentSize: 15),
            .init(categoryType: "포킷명", contentSize: 15),
            .init(categoryType: "포킷명", contentSize: 15),
            .init(categoryType: "포킷명", contentSize: 15),
            .init(categoryType: "포킷명", contentSize: 15),
            .init(categoryType: "포킷명", contentSize: 15),
            .init(categoryType: "포킷명", contentSize: 15),
            .init(categoryType: "포킷명", contentSize: 15),
            .init(categoryType: "포킷명", contentSize: 15),
            .init(categoryType: "포킷명", contentSize: 15),
            .init(categoryType: "포킷명", contentSize: 15),
            .init(categoryType: "포킷명", contentSize: 15),
            .init(categoryType: "포킷명", contentSize: 15),
            .init(categoryType: "포킷명", contentSize: 15),
            .init(categoryType: "포킷명", contentSize: 15),
            .init(categoryType: "포킷명", contentSize: 15),
            .init(categoryType: "포킷명", contentSize: 15),
            .init(categoryType: "포킷명", contentSize: 15),
            .init(categoryType: "포킷명", contentSize: 15),
            .init(categoryType: "포킷명", contentSize: 15),
            .init(categoryType: "포킷명", contentSize: 15),
            .init(categoryType: "포킷명", contentSize: 15),
            .init(categoryType: "포킷명", contentSize: 15),
            .init(categoryType: "포킷명", contentSize: 15),
            .init(categoryType: "포킷명", contentSize: 15),
            .init(categoryType: "포킷명", contentSize: 15)
        ]
    }
}
