//
//  PokitCategorySetting.swift
//  Domain
//
//  Created by 김도형 on 7/31/24.
//

import Foundation

public struct PokitCategorySetting {
    /// - Response
    public let categoryListInQuiry: BaseCategoryListInquiry
    public let imageList: [Self.Image]
    /// - Request
    public let pageable: BasePageable
    public let categoryName: String
    public let categoryImageName: Int
}

public extension PokitCategorySetting {
    struct Image {
        public let imageId: Int
        public let imageURL: String
    }
}
