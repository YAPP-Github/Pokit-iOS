//
//  CopiedCategoryRequest.swift
//  CoreKit
//
//  Created by 김도형 on 8/22/24.
//

import Foundation

public struct CopiedCategoryRequest: Encodable {
    public let originCategoryId: Int
    public var categoryName: String
    public var categoryImageId: Int
    public let keyword: String
    public let openType: String
    
    public init(
        originCategoryId: Int,
        categoryName: String,
        categoryImageId: Int,
        keyword: String,
        openType: String
    ) {
        self.originCategoryId = originCategoryId
        self.categoryName = categoryName
        self.categoryImageId = categoryImageId
        self.keyword = keyword
        self.openType = openType
    }
}
