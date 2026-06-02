//
//  ContentDetailResponse.swift
//  CoreKit
//
//  Created by 김도형 on 8/5/24.
//

import Foundation
import Util

public struct ContentDetailResponse: Decodable {
    public let contentId: Int
    public let category: BaseCategoryResponse
    public let data: String
    public let title: String
    public let memo: String
    public let alertYn: String
    public let createdAt: String
    public let favorites: Bool
    public let keyword: String?
    public let userNickname: String?
    public let authorUserId: Int?
    public let authorNickname: String?
    public let authorProfileImageURL: String?

    private enum CodingKeys: String, CodingKey {
        case contentId
        case category
        case data
        case title
        case memo
        case alertYn
        case createdAt
        case favorites
        case keyword
        case userNickname
        case author
        case authorUserId
        case authorNickname
        case authorProfileImageURL
    }

    private struct Author: Decodable {
        let userId: Int?
        let nickname: String?
        let profileImageUrl: String?
    }

    public init(
        contentId: Int,
        category: BaseCategoryResponse,
        data: String,
        title: String,
        memo: String,
        alertYn: String,
        createdAt: String,
        favorites: Bool,
        keyword: String? = nil,
        userNickname: String? = nil,
        authorUserId: Int? = nil,
        authorNickname: String? = nil,
        authorProfileImageURL: String? = nil
    ) {
        self.contentId = contentId
        self.category = category
        self.data = data
        self.title = title
        self.memo = memo
        self.alertYn = alertYn
        self.createdAt = createdAt
        self.favorites = favorites
        self.keyword = keyword
        self.userNickname = userNickname
        self.authorUserId = authorUserId
        self.authorNickname = authorNickname
        self.authorProfileImageURL = authorProfileImageURL
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let author = try container.decodeIfPresent(Author.self, forKey: .author)

        self.contentId = try container.decode(Int.self, forKey: .contentId)
        self.category = try container.decode(BaseCategoryResponse.self, forKey: .category)
        self.data = try container.decode(String.self, forKey: .data)
        self.title = try container.decode(String.self, forKey: .title)
        self.memo = try container.decode(String.self, forKey: .memo)
        self.alertYn = try container.decode(String.self, forKey: .alertYn)
        self.createdAt = try container.decode(String.self, forKey: .createdAt)
        self.favorites = try container.decode(Bool.self, forKey: .favorites)
        self.keyword = try container.decodeIfPresent(String.self, forKey: .keyword)
        self.userNickname = try container.decodeIfPresent(String.self, forKey: .userNickname)
        self.authorUserId = try container.decodeIfPresent(Int.self, forKey: .authorUserId) ?? author?.userId
        self.authorNickname = try container.decodeIfPresent(String.self, forKey: .authorNickname) ?? author?.nickname
        self.authorProfileImageURL = try container.decodeIfPresent(String.self, forKey: .authorProfileImageURL) ?? author?.profileImageUrl
    }
}

extension ContentDetailResponse {
    public static var mock: Self = Self(
        contentId: 512,
        category: BaseCategoryResponse(
            categoryId: 0,
            categoryName: "카테고리_이름임"
        ),
        data: "https://www.youtube.com/watch?v=wtSwdGJzQCQ",
        title: "신서유기",
        memo: "#티전드 #신서유기5 #신서유기7 #tvN\n회차정보 : 신서유기5 3회, 신서유기7 1회, 신서유기7 2회, 신서유기7 6회\n\n이제는 전설이 되어버린 역대급 장면들..\n묻지도 따지지도 않고 N회차 재생 가봅시다.",
        alertYn: "YES",
        createdAt: "2024-07-31T10:10:23.902Z",
        favorites: true,
        keyword: "예능",
        userNickname: "PokitMons",
        authorUserId: 100,
        authorNickname: "PokitMons",
        authorProfileImageURL: Constants.mockImageUrl
    )
}
