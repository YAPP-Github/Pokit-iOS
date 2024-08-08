//
//  Remind.swift
//  Domain
//
//  Created by 김도형 on 7/31/24.
//

import Foundation

import Util

public struct Remind: Equatable {
    // - MARK: Response
    /// 오늘의 추천 콘텐츠(링크) 리스트
    public var recommendedList: [BaseContent]
    /// 읽지 않은 콘텐츠(링크) 리스트
    public var unreadList: BaseContentListInquiry
    public var unreadListPageable: BasePageable
    /// 즐겨찾기한 콘텐츠(링크) 리스트
    public var favoriteList: BaseContentListInquiry
    public var favoriteListPageable: BasePageable
    
    public init() {
        self.recommendedList = []
        self.unreadList = .init(
            data: [],
            page: 0,
            size: 3,
            sort: [],
            hasNext: false
        )
        self.unreadListPageable = .init(
            page: 0,
            size: 3,
            sort: []
        )
        self.favoriteList = .init(
            data: [],
            page: 0,
            size: 3,
            sort: [],
            hasNext: false
        )
        self.favoriteListPageable = .init(
            page: 0,
            size: 3,
            sort: []
        )
    }
}
