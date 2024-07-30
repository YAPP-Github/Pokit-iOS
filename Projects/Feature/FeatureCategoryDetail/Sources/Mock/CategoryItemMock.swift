//
//  CategoryItemMock.swift
//  FeatureCategoryDetail
//
//  Created by 김민호 on 7/30/24.
//

import Foundation

import Util

public struct CategoryItemMock: PokitSelectItem, Identifiable {
    public var categoryType: String
    
    public var contentSize: Int
    
    public var id: UUID = .init()
    
    public init(
        categoryType: String,
        contentSize: Int
    ) {
        self.categoryType = categoryType
        self.contentSize = contentSize
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
