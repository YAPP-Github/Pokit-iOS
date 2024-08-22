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
    public var sharedCategory: SharedCategory?
    public var alert: Self.Alert?
    // - MARK: Request
    /// 복제할 카테고리(포킷) 정보
    public var copiedCategory: CopiedCategory?
    /// 조회할 카테고리(포킷) id
    public let categoryId: Int
    /// 조회할 페이징 정보
    public var pageable: BasePageable
    
    public init(categoryId: Int) {
        self.categoryId = categoryId
        self.pageable = .init(
            page: -1,
            size: 10,
            sort: ["desc"]
        )
    }
}

extension CategorySharing {
    public struct SharedCategory: Equatable {
        public let category: Category
        public var contentList: CategorySharing.ContentListInquiry
    }
    
    public struct CopiedCategory: Equatable {
        public let originCategoryId: Int
        public var categoryName: String
        
        public init(originCategoryId: Int, categoryName: String) {
            self.originCategoryId = originCategoryId
            self.categoryName = categoryName
        }
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
        public let memo: String
        public let thumbNail: String
        public let createdAt: String
        public let categoryName: String
        public let isRead: Bool = false
    }
}
