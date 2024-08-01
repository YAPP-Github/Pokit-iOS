//
//  CategoryEditRequest.swift
//  CoreKit
//
//  Created by 김민호 on 7/31/24.
//

import Foundation
/// 카테고리 추가 및 수정  API Request
public struct CategoryEditRequest: Encodable {
    let categoryName: String
    let categoryImageId: Int
}
