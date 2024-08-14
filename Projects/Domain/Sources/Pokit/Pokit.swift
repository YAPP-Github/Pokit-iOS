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
    
    public init() {
        self.categoryList = .init(
            data: [],
            page: 0,
            size: 10,
            sort: [],
            hasNext: false
        )
        self.unclassifiedContentList = .init(
            data: [],
            page: 0,
            size: 10,
            sort: [],
            hasNext: false
        )
    }
}
