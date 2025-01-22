//
//  PokitCategorySetting.swift
//  Domain
//
//  Created by 김도형 on 7/31/24.
//

import Foundation

import Util

public struct PokitCategorySetting: Equatable {
    // - MARK: Response
    /// 카테고리(포킷)에 설정할 수 있는 이미지
    public var imageList: [BaseCategoryImage]
    // - MARK: Request
    /// 조회할 페이징 정보
    public var pageable: BasePageable
    /// 등록할 카테고리(포킷) id
    public var categoryId: Int?
    /// 등록할 카테고리(포킷) 이름
    public var categoryName: String
    /// 등록할 카테고리(포킷) 이미지
    public var categoryImage: BaseCategoryImage?
    /// 카테고리 공개 여부(기본값: 공개)
    public var openType: BaseOpenType
    /// 카테고리 키워드(기본값: default - 미선택)
    public var keywordType: BaseInterestType
    
    public init(
        categoryId: Int?,
        categoryName: String?,
        categoryImage: BaseCategoryImage?,
        openType: BaseOpenType?,
        keywordType: BaseInterestType?
    ) {
        self.imageList = []
        self.pageable = .init(
            page: 0,
            size: 10,
            sort: []
        )
        self.categoryId = categoryId
        self.categoryName = categoryName ?? ""
        self.categoryImage = categoryImage
        self.openType = openType ?? .공개
        self.keywordType = keywordType ?? .default
    }
}
