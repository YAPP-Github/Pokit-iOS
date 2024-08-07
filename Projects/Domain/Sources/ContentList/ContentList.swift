//
//  LinkList.swift
//  Domain
//
//  Created by 김도형 on 8/6/24.
//

import Foundation

public struct ContentList: Equatable {
    // - MARK: Response
    /// 콘텐츠 목록
    public var contentList: BaseContentListInquiry
    
    public init() {
        self.contentList = .init(
            data: [],
            page: 0,
            size: 0,
            sort: [],
            hasNext: false
        )
    }
}
