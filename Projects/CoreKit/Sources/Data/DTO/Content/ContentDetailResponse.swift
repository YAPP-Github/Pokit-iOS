//
//  ContentDetailResponse.swift
//  CoreKit
//
//  Created by 김도형 on 8/5/24.
//

import Foundation

public struct ContentDetailResponse: Decodable {
    public let contentId: Int
    public let categoryId: Int
    public let categoryName: String
    public let data: String
    public let title: String
    public let memo: String
    public let alertYn: String
    public let createdAt: String
    public let favorites: Bool
}

extension ContentDetailResponse {
    public static var mock: Self = Self(
        contentId: 512,
        categoryId: 992,
        categoryName: "미분류",
        data: "https://www.youtube.com/watch?v=wtSwdGJzQCQ",
        title: "신서유기",
        memo: "#티전드 #신서유기5 #신서유기7 #tvN\n회차정보 : 신서유기5 3회, 신서유기7 1회, 신서유기7 2회, 신서유기7 6회\n\n이제는 전설이 되어버린 역대급 장면들..\n묻지도 따지지도 않고 N회차 재생 가봅시다.",
        alertYn: "YES",
        createdAt: "2024-07-31T10:10:23.902Z",
        favorites: true
    )
}
