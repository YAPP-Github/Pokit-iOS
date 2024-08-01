//
//  CategoryCountResponse.swift
//  CoreKit
//
//  Created by 김민호 on 7/31/24.
//

import Foundation
/// 유저 카테고리 개수 조회 API Response
public struct CategoryCountResponse: Decodable {
    let categoryTotalCount: Int
}

extension CategoryCountResponse {
    public static var mock: Self = Self(categoryTotalCount: 4)
}

