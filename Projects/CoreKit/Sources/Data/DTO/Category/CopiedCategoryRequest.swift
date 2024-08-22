//
//  CopiedCategoryRequest.swift
//  CoreKit
//
//  Created by 김도형 on 8/22/24.
//

import Foundation

public struct CopiedCategoryRequest: Decodable {
    public let originCategoryId: Int
    public var categoryName: String
    
    public init(
        originCategoryId: Int,
        categoryName: String
    ) {
        self.originCategoryId = originCategoryId
        self.categoryName = categoryName
    }
}
