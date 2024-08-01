//
//  PokitCategorySetting.swift
//  Domain
//
//  Created by 김도형 on 7/31/24.
//

import Foundation

public struct PokitCategorySetting {
    // - MARK: Response
    /// 카테고리(포킷) 리스트
    public let categoryListInQuiry: BaseCategoryListInquiry
    /// 카테고리(포킷)에 설정할 수 있는 이미지
    public let imageList: [BaseCategoryImage]
    /// 유저가 등록한 카테고리(포킷) 개수
    public let categoryTotalCount: Int
    // - MARK: Request
    /// 조회할 페이징 정보
    public let pageable: BasePageable
    /// 등록할 카테고리(포킷) 이름
    public let categoryName: String
    /// 등록할 카테고리(포킷) 이미지 이름
    public let categoryImageName: Int
}
