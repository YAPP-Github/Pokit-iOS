//
//  CategorySharing.swift
//  Domain
//
//  Created by 김도형 on 8/21/24.
//

import Foundation

public struct CategorySharing: Equatable {
    // - MARK: Response
    /// 공유받은 카테고리(포킷)
    public var sharedCategory: SharedCategory?
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
            page: 0,
            size: 10,
            sort: ["desc"]
        )
    }
}

extension CategorySharing {
    public struct SharedCategory: Equatable {
        public let category: Category
        public var contentList: BaseContentListInquiry
    }
    
    public struct CopiedCategory: Equatable {
        public let originCategoryId: Int
        public var categoryName: String
    }
}

extension CategorySharing.SharedCategory {
    public struct Category: Equatable {
        public let categoryId: Int
        public let categoryName: String
        public let contentCount: Int
    }
}
