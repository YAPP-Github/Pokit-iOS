//
//  Search.swift
//  Domain
//
//  Created by 김도형 on 8/5/24.
//

import Foundation

public struct Search: Equatable {
    // - MARK: Response
    /// 검색된 콘텐츠(링크) 리스트
    public var contentList: BaseContentListInquiry
    // - MARK: Request
    /// 검색 조건
    public var condition: Condition
    /// 조회할 페이징 정보
    public var pageable: BasePageable
    
    public init() {
        self.contentList = .init(
            data: [],
            page: 0,
            size: 10,
            sort: [],
            hasNext: false
        )
        self.condition = .init(
            searchWord: "",
            categoryIds: [],
            isRead: false,
            favorites: false
        )
        self.pageable = .init(
            page: 0,
            size: 10,
            sort: ["desc"]
        )
    }
}

extension Search {
    public struct Condition: Equatable {
        public var searchWord: String
        public var categoryIds: [Int]
        public var isRead: Bool
        public var favorites: Bool
        public var startDate: Date?
        public var endDate: Date?
    }
}
