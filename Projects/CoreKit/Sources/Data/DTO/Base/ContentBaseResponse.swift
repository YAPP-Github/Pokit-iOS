//
//  ContentBaseResponse.swift
//  CoreKit
//
//  Created by 김민호 on 7/31/24.
//

import Foundation
import Util
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
    public let authorUserId: Int?
    public let authorNickname: String?
    public let authorProfileImageURL: String?

    private enum CodingKeys: String, CodingKey {
        case contentId
        case category
        case data
        case domain
        case title
        case memo
        case thumbNail
        case createdAt
        case isRead
        case isFavorite
        case keyword
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
        category: Category,
        data: String,
        domain: String,
        title: String,
        memo: String?,
        thumbNail: String,
        createdAt: String,
        isRead: Bool?,
        isFavorite: Bool?,
        keyword: String? = nil,
        authorUserId: Int? = nil,
        authorNickname: String? = nil,
        authorProfileImageURL: String? = nil
    ) {
        self.contentId = contentId
        self.category = category
        self.data = data
        self.domain = domain
        self.title = title
        self.memo = memo
        self.thumbNail = thumbNail
        self.createdAt = createdAt
        self.isRead = isRead
        self.isFavorite = isFavorite
        self.keyword = keyword
        self.authorUserId = authorUserId
        self.authorNickname = authorNickname
        self.authorProfileImageURL = authorProfileImageURL
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let author = try container.decodeIfPresent(Author.self, forKey: .author)

        self.contentId = try container.decode(Int.self, forKey: .contentId)
        self.category = try container.decode(Category.self, forKey: .category)
        self.data = try container.decode(String.self, forKey: .data)
        self.domain = try container.decode(String.self, forKey: .domain)
        self.title = try container.decode(String.self, forKey: .title)
        self.memo = try container.decodeIfPresent(String.self, forKey: .memo)
        self.thumbNail = try container.decode(String.self, forKey: .thumbNail)
        self.createdAt = try container.decode(String.self, forKey: .createdAt)
        self.isRead = try container.decodeIfPresent(Bool.self, forKey: .isRead)
        self.isFavorite = try container.decodeIfPresent(Bool.self, forKey: .isFavorite)
        self.keyword = try container.decodeIfPresent(String.self, forKey: .keyword)
        self.authorUserId = try container.decodeIfPresent(Int.self, forKey: .authorUserId) ?? author?.userId
        self.authorNickname = try container.decodeIfPresent(String.self, forKey: .authorNickname) ?? author?.nickname
        self.authorProfileImageURL = try container.decodeIfPresent(String.self, forKey: .authorProfileImageURL) ?? author?.profileImageUrl
    }
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
            keyword: "예능",
            authorUserId: 1000 + id,
            authorNickname: "Author-\(id)",
            authorProfileImageURL: Constants.mockImageUrl
        )
    }
}

extension ContentBaseResponse {
    public struct Category: Decodable {
        public let categoryId: Int
        public let categoryName: String
    }
}
