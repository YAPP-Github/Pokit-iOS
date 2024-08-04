//
//  PokitMock.swift
//  FeatureMyPage
//
//  Created by 김도형 on 7/17/24.
//

import Foundation
import Util

public struct PokitMock: PokitSelectItem, Identifiable {
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
    
    static var addLinkMock: [PokitMock] {
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
