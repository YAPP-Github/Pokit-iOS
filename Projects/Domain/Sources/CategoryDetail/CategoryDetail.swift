//
//  CategoryDetail.swift
//  Domain
//
//  Created by 김도형 on 7/31/24.
//

import Foundation

public struct CategoryDetail: Equatable {
    // - MARK: Respone
    /// 카테고리(포킷)
    public var category: BaseCategory
    /// - 카테고리(포킷) 리스트
    public var categoryListInQuiry: BaseCategoryListInquiry
    /// 카테고리(포킷) 내 콘텐츠(링크) 리스트
    public var contentList: BaseContentListInquiry
    // - MARK: Request
    /// 조회할 페이징 정보
    public var pageable: BasePageable
    
    public init(categpry: BaseCategory) {
        self.category = categpry
        let categoryListInquiry = BaseCategoryListInquiry(
            data: [],
            page: 0,
            size: 0,
            sort: [],
            hasNext: false
        )
        self.categoryListInQuiry = categoryListInquiry
        self.contentList = .init(
            data: [],
            page: 0,
            size: 0,
            sort: [],
            hasNext: false
        )
        self.pageable = .init(
            page: 0,
            size: 10,
            sort: []
        )
    }
}
