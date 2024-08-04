//
//  BaseContent.swift
//  Domain
//
//  Created by 김도형 on 7/31/24.
//

import Foundation

import Util

public struct BaseContent: Identifiable, Equatable, PokitLinkCardItem {
    public let id: Int
    public let categoryName: String
    public let categoryId: Int?
    public let title: String
    public let thumbNail: String
    public let data: String
    public let memo: String
    public let createdAt: Date
    public let isRead: Bool
    public let favorites: Bool
    public let alertYn: RemindState
    
    public init(
        id: Int,
        categoryName: String,
        categoryId: Int?,
        title: String,
        thumbNail: String,
        data: String,
        memo: String,
        createdAt: Date,
        isRead: Bool,
        favorites: Bool,
        alertYn: RemindState
    ) {
        self.id = id
        self.categoryName = categoryName
        self.categoryId = categoryId
        self.title = title
        self.thumbNail = thumbNail
        self.data = data
        self.memo = memo
        self.createdAt = createdAt
        self.isRead = isRead
        self.favorites = favorites
        self.alertYn = alertYn
    }
}

public extension BaseContent {
    enum RemindState: String, Equatable {
        case yes = "YES"
        case no = "NO"
    }
}
