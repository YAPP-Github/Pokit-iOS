//
//  BaseContent.swift
//  Domain
//
//  Created by 김도형 on 7/31/24.
//

import Foundation

import Util

public struct BaseContentItem: Identifiable, Equatable, PokitLinkCardItem, Sortable {
    public let id: Int
    public let categoryName: String
    public let categoryId: Int
    public let title: String
    public var memo: String?
    public var thumbNail: String
    public let data: String
    public let domain: String
    public let createdAt: String
    public let isRead: Bool?
    public let isFavorite: Bool?
    
    public init(
        id: Int,
        categoryName: String,
        categoryId: Int,
        title: String,
        memo: String?,
        thumbNail: String,
        data: String,
        domain: String,
        createdAt: String,
        isRead: Bool?,
        isFavorite: Bool?
    ) {
        self.id = id
        self.categoryName = categoryName
        self.categoryId = categoryId
        self.title = title
        self.memo = memo
        self.thumbNail = thumbNail
        self.data = data
        self.domain = domain
        self.createdAt = createdAt
        self.isRead = isRead
        self.isFavorite = isFavorite
    }
}
