//
//  LinkDetail.swift
//  Domain
//
//  Created by 김도형 on 8/1/24.
//

import Foundation

public struct LinkDetail {
    // - MARK: Response
    /// 콘텐츠(링크) 상세
    public let content: BaseContent
}

public extension LinkDetail {
    struct Content {
        public let id: Int
        public let categoryName: String
        public let categoryId: Int?
        public let title: String
        public let thumbNail: String
        public let data: String
        public let memo: String
        public let createdAt: Date
        public let favorites: Bool
        public let alertYn: BaseContent.RemindState
    }
}
