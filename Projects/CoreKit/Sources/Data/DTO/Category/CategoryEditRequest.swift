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
    
    public init(categoryName: String, categoryImageId: Int) {
        self.categoryName = categoryName
        self.categoryImageId = categoryImageId
    }
}
