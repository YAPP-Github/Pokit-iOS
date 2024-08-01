//
//  ContentBaseResponse.swift
//  CoreKit
//
//  Created by 김민호 on 7/31/24.
//

import Foundation
/// 컨텐츠 상세조회, 컨텐츠 수정, 컨텐츠 추가 API Response
public struct ContentBaseResponse: Decodable {
    let contentId: Int
    let categoryId: Int
    let data: String
    let title: String
    let memo: String
    let alertYn: String
    let createdAt: String
    let favorites: Bool
}

extension ContentBaseResponse {
    public static var mock: Self = Self(
        contentId: 512,
        categoryId: 992,
        data: "Data(Mock)",
        title: "Title(Mock)",
        memo: "MEMO(Mock)",
        alertYn: "AAAA",
        createdAt: "2024-07-31T10:10:23.902Z",
        favorites: true
    )
}
