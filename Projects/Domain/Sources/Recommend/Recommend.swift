//
//  Recommend.swift
//  Domain
//
//  Created by 김도형 on 1/29/25.
//

import Foundation

public struct Recommend: Equatable {
    // - MARK: Response
    /// 콘텐츠 목록
    public var contentList: BaseContentListInquiry
    public var pageable: BasePageable
    public var myInterests: [BaseInterest]
    public var interests: [BaseInterest]
    /// 카테고리(포킷) 리스트
    public var categoryListInQuiry: BaseCategoryListInquiry
    
    public init() {
        self.contentList = .init(
            page: 0,
            size: 0,
            sort: [],
            hasNext: false
        )
        self.pageable = .init(
            page: 0, size: 10,
            sort: ["createdAt,desc"]
        )
        self.myInterests = []
        self.interests = []
        self.categoryListInQuiry = BaseCategoryListInquiry(
            data: [],
            page: 0,
            size: 0,
            sort: [],
            hasNext: false
        )
    }
}
