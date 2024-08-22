//
//  BaseContentDetail.swift
//  Domain
//
//  Created by 김도형 on 8/9/24.
//

import Foundation

public struct BaseContentDetail: Equatable {
    public let id: Int
    public let category: BaseCategoryInfo
    public let title: String
    public let data: String
    public let memo: String
    public let createdAt: String
    public var favorites: Bool?
    public var alertYn: RemindState
    
    public init(
        id: Int,
        category: BaseCategoryInfo,
        title: String,
        data: String,
        memo: String,
        createdAt: String,
        favorites: Bool?,
        alertYn: RemindState
    ) {
        self.id = id
        self.category = category
        self.title = title
        self.data = data
        self.memo = memo
        self.createdAt = createdAt
        self.favorites = favorites
        self.alertYn = alertYn
    }
}

public extension BaseContentDetail {
    enum RemindState: String, Equatable {
        case yes = "YES"
        case no = "NO"
    }
}

/// CategoryId & CategoryName
public struct BaseCategoryInfo: Equatable {
    public let categoryId: Int
    public let categoryName: String
    
    public init(categoryId: Int, categoryName: String) {
        self.categoryId = categoryId
        self.categoryName = categoryName
    }
}
