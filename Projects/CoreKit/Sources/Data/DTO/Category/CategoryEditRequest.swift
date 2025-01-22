//
//  CategoryEditRequest.swift
//  CoreKit
//
//  Created by 김민호 on 7/31/24.
//

import Foundation
/// 카테고리 추가 및 수정  API Request
public struct CategoryEditRequest: Encodable {
    public let categoryName: String
    public let categoryImageId: Int
    public let openType: String
    public let keywordType: String
    
    public init(
        categoryName: String,
        categoryImageId: Int,
        openType: String,
        keywordType: String
    ) {
        self.categoryName = categoryName
        self.categoryImageId = categoryImageId
        self.openType = openType
        self.keywordType = keywordType
    }
}
