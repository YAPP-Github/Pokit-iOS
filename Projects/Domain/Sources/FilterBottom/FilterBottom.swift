//
//  FilterBottom.swift
//  Domain
//
//  Created by 김도형 on 8/5/24.
//

import Foundation

public struct FilterBottom: Equatable {
    // - MARK: Response
    /// 카테고리(포킷) 리스트
    public var categoryList: BaseCategoryListInquiry
    
    // - MARK: Request
    /// 조회할 페이징 정보
    public var pageable: BasePageable
    
    public init() {
        self.categoryList = .init(
            page: 0,
            size: 10,
            sort: [],
            hasNext: false
        )
        self.pageable = .init(
            page: 0,
            size: 10,
            sort: ["desc"]
        )
    }
}
