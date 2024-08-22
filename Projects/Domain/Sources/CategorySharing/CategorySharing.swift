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
    public var category: SharedCategory?
    // - MARK: Request
    /// 복제할 카테고리(포킷) 정보
    public var copiedCategory: CopiedCategory?
    /// 조회할 카테고리(포킷) id
    public let categoryId: Int
    
    public init(categoryId: Int) {
        self.categoryId = categoryId
    }
}

extension CategorySharing {
    public struct SharedCategory: Equatable {
        public let category: Category
        public var contents: BaseContentListInquiry
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
