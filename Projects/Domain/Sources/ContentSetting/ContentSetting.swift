//
//  AddLink.swift
//  Domain
//
//  Created by 김도형 on 7/31/24.
//

import Foundation

public struct ContentSetting: Equatable {
    // - MARK: Response
    /// 조회할 콘텐츠(링크)
    public var content: BaseContentDetail?
    /// 카테고리(포킷) 리스트
    public var categoryListInQuiry: BaseCategoryListInquiry
    /// 유저가 등록한 카테고리(포킷) 개수
    public var categoryTotalCount: Int
    // - MARK: Request
    /// 수정할 콘텐츠(링크) id
    public var contentId: Int?
    /// 등록 또는 수정할 콘텐츠(링크) url
    public var data: String
    /// 등록 또는 수정할 콘텐츠(링크) 제목
    public var title: String
    /// 등록 또는 수정할 콘텐츠(링크) 카테고리 id
    public var categoryId: Int?
    /// 등록 또는 수정할 콘텐츠(링크) 메모
    public var memo: String
    /// 등록 또는 수정할 콘텐츠(링크) 리마인드 여부
    public var alertYn: BaseContentDetail.RemindState
    /// 카테고리 리스트의 조회할 페이징 정보
    public var pageable: BasePageable
    
    public init(contentId: Int?, data: String?) {
        self.contentId = contentId
        
        let categoryListInquiry = BaseCategoryListInquiry(
            data: [],
            page: 0,
            size: 0,
            sort: [],
            hasNext: false
        )
        
        self.categoryListInQuiry = categoryListInquiry
        self.categoryTotalCount = categoryListInquiry.data?.count ?? 0
        self.data = content?.data ?? data ?? ""
        self.title = content?.title ?? ""
        self.categoryId = content?.categoryId
        self.memo = content?.memo ?? ""
        self.alertYn = content?.alertYn ?? .no
        self.pageable = .init(
            page: 0,
            size: 10,
            sort: ["desc"]
        )
    }
}
