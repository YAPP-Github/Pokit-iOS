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
    public let category: Category
    public let data: String
    public let domain: String
    public let title: String
    public let memo: String?
    public let thumbNail: String
    public let createdAt: String
    public let isRead: Bool?
    public let isFavorite: Bool?
    public let keyword: String?
}

extension ContentBaseResponse {
    public static func mock(id: Int) -> Self {
        Self(
            contentId: id,
            category: .init(
                categoryId: 567,
                categoryName: "신서유기"
            ),
            data: "https://youtu.be/CIzKDrN7IpU?si=B0-7X7I_54VHAfkk",
            domain: "youtube",
            title: "[#샷추가] 거리 두기 철저하게 지키게 만드는 인물 퀴즈ㅋㅋㅋ어떤 음식을 뺄지 고민하지 마요..어차피 다 못 먹으니까요🤣 | #신서유기5 #Diggle",
            memo: nil,
            thumbNail: "https://i.ytimg.com/vi/CIzKDrN7IpU/maxresdefault.jpg",
            createdAt: "2024.12.03",
            isRead: false,
            isFavorite: true,
            keyword: "예능"
        )
    }
}

extension ContentBaseResponse {
    public struct Category: Decodable {
        public let categoryId: Int
        public let categoryName: String
    }
}
