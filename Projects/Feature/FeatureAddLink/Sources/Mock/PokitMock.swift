//
//  PokitMock.swift
//  FeatureMyPage
//
//  Created by 김도형 on 7/17/24.
//

import Foundation
import Util

public struct PokitMock: PokitSelectItem, Identifiable {
    public var categoryType: String
    
    public var contentSize: Int
    
    public var id: UUID = .init()
    
    init(
        categoryType: String,
        contentSize: Int
    ) {
        self.categoryType = categoryType
        self.contentSize = contentSize
    }
    
    static var addLinkMock: [PokitMock] {
        return [
            .init(categoryType: "미분류", contentSize: 15),
            .init(categoryType: "포킷명", contentSize: 15)
        ]
    }
}
