//
//  LinkDetail.swift
//  Domain
//
//  Created by 김도형 on 8/1/24.
//

import Foundation

public struct ContentDetail: Equatable {
    // - MARK: Response
    /// 콘텐츠(링크) 상세
    public var content: ContentDetail.Content?
    // - MARK: Request
    /// 조회할 콘텐츠 id
    public let contentId: Int
    
    public init(
        content: ContentDetail.Content? = nil,
        contentId: Int
    ) {
        self.content = content
        self.contentId = contentId
    }
}

public extension ContentDetail {
    struct Content: Equatable {
        public let id: Int
        public let categoryName: String
        public let categoryId: Int?
        public let title: String
        public let data: String
        public let memo: String
        public let createdAt: Date
        public var favorites: Bool
        public var alertYn: RemindState
        
        public init(
            id: Int,
            categoryName: String,
            categoryId: Int?,
            title: String,
            data: String,
            memo: String,
            createdAt: Date,
            favorites: Bool,
            alertYn: RemindState
        ) {
            self.id = id
            self.categoryName = categoryName
            self.categoryId = categoryId
            self.title = title
            self.data = data
            self.memo = memo
            self.createdAt = createdAt
            self.favorites = favorites
            self.alertYn = alertYn
        }
    }
}

public extension ContentDetail.Content {
    enum RemindState: String, Equatable {
        case yes = "YES"
        case no = "NO"
    }
}
