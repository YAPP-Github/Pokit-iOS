//
//  CategorySharing.swift
//  Domain
//
//  Created by 김도형 on 8/21/24.
//

import Foundation

import Util

public struct CategorySharing: Equatable {
    // - MARK: Response
    /// 공유받은 카테고리(포킷)
    public var sharedCategory: SharedCategory
    /// 조회할 페이징 정보
    public var pageable: BasePageable
    
    public init(
        sharedCategory: SharedCategory,
        pageable: BasePageable
    ) {
        self.sharedCategory = sharedCategory
        self.pageable = pageable
    }
}

extension CategorySharing {
    public struct SharedCategory: Equatable {
        public let category: Category
        public var contentList: CategorySharing.ContentListInquiry
    }
    
    public struct Alert: Equatable, Identifiable {
        public let id = UUID()
        public let titleKey: String
        public let message: String
        
        public init(titleKey: String, message: String) {
            self.titleKey = titleKey
            self.message = message
        }
    }
    
    public struct Category: Equatable {
        public let categoryId: Int
        public let categoryName: String
        public let contentCount: Int
        public let categoryImageId: Int
        public let categoryImageUrl: String
    }
    
    public struct ContentListInquiry: Equatable {
        public let data: [CategorySharing.Content]
        public let page: Int
        public let size: Int
        public let sort: [BaseItemInquirySort]
        public let hasNext: Bool
    }
    
    public struct Content: Identifiable, Equatable, PokitLinkCardItem {
        public let id: Int
        public let data: String
        public let domain: String
        public let title: String
        public let memo: String?
        public let thumbNail: String
        public let createdAt: String
        public let categoryName: String
        public let isRead: Bool?
        public let isFavorite: Bool?
        public let authorUserId: Int?
        public let authorNickname: String?
        public let authorProfileImageURL: String?

        public init(
            id: Int,
            data: String,
            domain: String,
            title: String,
            memo: String?,
            thumbNail: String,
            createdAt: String,
            categoryName: String,
            isRead: Bool? = false,
            isFavorite: Bool? = false,
            authorUserId: Int? = nil,
            authorNickname: String? = nil,
            authorProfileImageURL: String? = nil
        ) {
            self.id = id
            self.data = data
            self.domain = domain
            self.title = title
            self.memo = memo
            self.thumbNail = thumbNail
            self.createdAt = createdAt
            self.categoryName = categoryName
            self.isRead = isRead
            self.isFavorite = isFavorite
            self.authorUserId = authorUserId
            self.authorNickname = authorNickname
            self.authorProfileImageURL = authorProfileImageURL
        }
    }
}
