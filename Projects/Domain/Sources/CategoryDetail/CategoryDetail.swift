//
//  CategoryDetail.swift
//  Domain
//
//  Created by 김도형 on 7/31/24.
//

import Foundation

public struct CategoryDetail {
    // - MARK: Respone
    /// 카테고리(포킷) 내 콘텐츠(링크) 리스트
    public let contentList: BaseContentListInquiry
    // - MARK: Request
    /// 조회할 페이징 정보
    public let pageable: BasePageable
}
