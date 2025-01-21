//
//  PokitCategorySetting.swift
//  Domain
//
//  Created by 김도형 on 7/31/24.
//

import Foundation

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
    
    public init(
        categoryId: Int?,
        categoryName: String?,
        categoryImage: BaseCategoryImage?
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
    }
}
