//
//  Pokit.swift
//  Domain
//
//  Created by 김도형 on 8/1/24.
//

import Foundation

public struct Pokit {
    // - MARK: Response
    /// 카테고리(포킷) 리스트
    public let categoryList: BaseCategoryListInquiry
    /// 컨텐트(링크) 리스트
    public let unclassifiedContentList: BaseContentListInquiry
}
