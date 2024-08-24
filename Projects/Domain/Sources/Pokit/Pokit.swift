//
//  Pokit.swift
//  Domain
//
//  Created by 김도형 on 8/1/24.
//

import Foundation

public struct Pokit: Equatable {
    // - MARK: Response
    /// 카테고리(포킷) 리스트
    public var categoryList: BaseCategoryListInquiry
    /// 컨텐트(링크) 리스트
    public var unclassifiedContentList: BaseContentListInquiry
    
    public var pageable: BasePageable
    
    public init() {
        self.categoryList = .init(
            page: 0,
            size: 10,
            sort: [],
            hasNext: false
        )
        self.unclassifiedContentList = .init(
            page: 0,
            size: 10,
            sort: [],
            hasNext: false
        )
        
        self.pageable = .init(
            page: -1,
            size: 10,
            sort: ["createdAt,desc"]
        )
    }
}
