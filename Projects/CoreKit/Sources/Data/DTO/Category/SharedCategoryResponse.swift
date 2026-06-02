//
//  SharedCategoryResponse.swift
//  CoreKit
//
//  Created by 김도형 on 8/22/24.
//

import Foundation

import Util

public struct SharedCategoryResponse: Decodable {
    public let category: Category
    public var contents: Self.ContentListInquiry
}

extension SharedCategoryResponse {
    public static var mock: Self = .init(
        category: .init(
            categoryId: 0,
            categoryName: "카테고리_이름임",
            contentCount: 3,
            categoryImageId: 2312,
            categoryImageUrl: Constants.mockImageUrl
        ),
        contents: .mock
    )
}

extension SharedCategoryResponse {
    public struct Category: Decodable {
        public let categoryId: Int
        public let categoryName: String
        public let contentCount: Int
        public let categoryImageId: Int
        public let categoryImageUrl: String
    }
    
    public struct ContentListInquiry: Decodable {
        public let data: [SharedCategoryResponse.Content]
        public let page: Int
        public let size: Int
        public let sort: [ItemInquirySortResponse]
        public let hasNext: Bool
    }
    
    public struct Content: Decodable {
        public let contentId: Int
        public let data: String
        public let domain: String
        public let title: String
        public let memo: String
        public let thumbNail: String
        public let createdAt: String
        public let authorUserId: Int?
        public let authorNickname: String?
        public let authorProfileImageURL: String?

        private enum CodingKeys: String, CodingKey {
            case contentId
            case data
            case domain
            case title
            case memo
            case thumbNail
            case createdAt
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
            data: String,
            domain: String,
            title: String,
            memo: String,
            thumbNail: String,
            createdAt: String,
            authorUserId: Int? = nil,
            authorNickname: String? = nil,
            authorProfileImageURL: String? = nil
        ) {
            self.contentId = contentId
            self.data = data
            self.domain = domain
            self.title = title
            self.memo = memo
            self.thumbNail = thumbNail
            self.createdAt = createdAt
            self.authorUserId = authorUserId
            self.authorNickname = authorNickname
            self.authorProfileImageURL = authorProfileImageURL
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let author = try container.decodeIfPresent(Author.self, forKey: .author)
            self.contentId = try container.decode(Int.self, forKey: .contentId)
            self.data = try container.decode(String.self, forKey: .data)
            self.domain = try container.decode(String.self, forKey: .domain)
            self.title = try container.decode(String.self, forKey: .title)
            self.memo = try container.decode(String.self, forKey: .memo)
            self.thumbNail = try container.decode(String.self, forKey: .thumbNail)
            self.createdAt = try container.decode(String.self, forKey: .createdAt)
            self.authorUserId = try container.decodeIfPresent(Int.self, forKey: .authorUserId) ?? author?.userId
            self.authorNickname = try container.decodeIfPresent(String.self, forKey: .authorNickname) ?? author?.nickname
            self.authorProfileImageURL = try container.decodeIfPresent(String.self, forKey: .authorProfileImageURL) ?? author?.profileImageUrl
        }
    }
}

extension SharedCategoryResponse.Content {
    public static func mock(id: Int) -> Self {
        Self(
            contentId: id,
            data: "https://www.youtube.com/watch?v=wtSwdGJzQCQ",
            domain: "youtube",
            title: "신서유기",
            memo: "신서유기는 재밌어",
            thumbNail: "https://i.ytimg.com/vi/NnOC4_kH0ok/hqdefault.jpg?sqp=-oaymwEjCNACELwBSFryq4qpAxUIARUAAAAAGAElAADIQj0AgKJDeAE=&rs=AOn4CLDN6u6mTjbaVmRZ4biJS_aDq4uvAQ",
            createdAt: "2024.08.08",
            authorUserId: 100,
            authorNickname: "PokitMons",
            authorProfileImageURL: Constants.mockImageUrl
        )
    }
}

extension SharedCategoryResponse.ContentListInquiry {
    public static var mock: Self = Self(
        data: [
            SharedCategoryResponse.Content.mock(id: 0),
            SharedCategoryResponse.Content.mock(id: 1),
            SharedCategoryResponse.Content.mock(id: 2)
        ],
        page: 0,
        size: 4,
        sort: [
            ItemInquirySortResponse(
                direction: "",
                nullHandling: "",
                ascending: false,
                property: "",
                ignoreCase: false
            )
        ],
        hasNext: false
    )
}
