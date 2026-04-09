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
    public var isRead: Bool?
    public var isFavorite: Bool?
    public let keyword: String?
    public let authorUserId: Int?
    public let authorNickname: String?
    public let authorProfileImageURL: String?
    
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
        isFavorite: Bool?,
        keyword: String? = nil,
        authorUserId: Int? = nil,
        authorNickname: String? = nil,
        authorProfileImageURL: String? = nil
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
        self.keyword = keyword
        self.authorUserId = authorUserId
        self.authorNickname = authorNickname
        self.authorProfileImageURL = authorProfileImageURL
    }
}
