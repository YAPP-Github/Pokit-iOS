//
//  SearchPokitMock.swift
//  FeatureSetting
//
//  Created by 김도형 on 7/27/24.
//

import Foundation
import Util

public struct SearchPokitMock: PokitSelectItem, Identifiable {
    public var categoryName: String
    
    public var contentSize: Int
    
    public var id: UUID = .init()
    
    public init(
        categoryType: String,
        contentSize: Int
    ) {
        self.categoryName = categoryType
        self.contentSize = contentSize
    }
    
    static var addLinkMock: [SearchPokitMock] {
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
