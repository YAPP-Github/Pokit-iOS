//
//  ContentBaseResponse.swift
//  CoreKit
//
//  Created by 김민호 on 7/31/24.
//

import Foundation
/// 컨텐츠 상세조회, 컨텐츠 수정, 컨텐츠 추가 API Response
public struct ContentBaseResponse: Decodable {
    public let contentId: Int
    public let categoryId: Int
    public let categoryName: String
    public let data: String
    public let domain: String
    public let title: String
    public let thumbNail: String
    public let memo: String
    public let alertYn: String
    public let createdAt: String
    public let isRead: Bool
    public let favorites: Bool
}

extension ContentBaseResponse {
    public static func mock(id: Int) -> Self {
        Self(
            contentId: id,
            categoryId: 992,
            categoryName: "미분류",
            data: "https://www.youtube.com/watch?v=wtSwdGJzQCQ",
            domain: "youtube",
            title: "신서유기",
            thumbNail: "https://i.ytimg.com/vi/NnOC4_kH0ok/hqdefault.jpg?sqp=-oaymwEjCNACELwBSFryq4qpAxUIARUAAAAAGAElAADIQj0AgKJDeAE=&rs=AOn4CLDN6u6mTjbaVmRZ4biJS_aDq4uvAQ",
            memo: "#티전드 #신서유기5 #신서유기7 #tvN\n회차정보 : 신서유기5 3회, 신서유기7 1회, 신서유기7 2회, 신서유기7 6회\n\n이제는 전설이 되어버린 역대급 장면들..\n묻지도 따지지도 않고 N회차 재생 가봅시다.",
            alertYn: "YES",
            createdAt: "2024-07-31T10:10:23.902Z",
            isRead: false,
            favorites: true
        )
    }
}
