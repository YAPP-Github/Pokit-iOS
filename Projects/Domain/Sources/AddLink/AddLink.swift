//
//  AddLink.swift
//  Domain
//
//  Created by 김도형 on 7/31/24.
//

import Foundation

public struct AddLink {
    // - MARK: Response
    /// 조회할 콘텐츠(링크)
    public let content: BaseContent
    /// 카테고리(포킷) 리스트
    public let categoryListInQuiry: BaseCategoryListInquiry
    /// 유저가 등록한 카테고리(포킷) 개수
    public let categoryTotalCount: Int
    // - MARK: Request
    /// 등록 또는 수정할 콘텐츠(링크) url
    public let data: String
    /// 등록 또는 수정할 콘텐츠(링크) 제목
    public let title: String
    /// 등록 또는 수정할 콘텐츠(링크) 카테고리 id
    public let categoryId: Int
    /// 등록 또는 수정할 콘텐츠(링크) 메모
    public let memo: String
    /// 등록 또는 수정할 콘텐츠(링크) 리마인드 여부
    public let alertYn: RemindState
    /// 카테고리 리스트의 조회할 페이징 정보
    public let pageable: BasePageable
}

public extension AddLink {
    enum RemindState: String {
        case yes = "YES"
        case no = "NO"
    }
}
