//
//  BaseContent.swift
//  Domain
//
//  Created by 김도형 on 7/31/24.
//

import Foundation

import Util

public struct BaseContentItem: Identifiable, Equatable, PokitLinkCardItem {
    public let id: Int
    public let categoryName: String
    public let categoryId: Int
    public let title: String
    public let thumbNail: String
    public let data: String
    public let domain: String
    public let createdAt: String
    public let isRead: Bool
    
    public init(
        id: Int,
        categoryName: String,
        categoryId: Int,
        title: String,
        thumbNail: String,
        data: String,
        domain: String,
        createdAt: String,
        isRead: Bool
    ) {
        self.id = id
        self.categoryName = categoryName
        self.categoryId = categoryId
        self.title = title
        self.thumbNail = thumbNail
        self.data = data
        self.domain = domain
        self.createdAt = createdAt
        self.isRead = isRead
    }
}
