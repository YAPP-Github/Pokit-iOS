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
    public let thumbNail: String
    public let createdAt: String
    public let isRead: Bool?
}

extension ContentBaseResponse {
    public static func mock(id: Int) -> Self {
        Self(
            contentId: id,
            category: .init(
                categoryId: 992,
                categoryName: "미분류"
            ),
            data: "https://www.youtube.com/watch?v=wtSwdGJzQCQ",
            domain: "youtube",
            title: "신서유기",
            thumbNail: "https://i.ytimg.com/vi/NnOC4_kH0ok/hqdefault.jpg?sqp=-oaymwEjCNACELwBSFryq4qpAxUIARUAAAAAGAElAADIQj0AgKJDeAE=&rs=AOn4CLDN6u6mTjbaVmRZ4biJS_aDq4uvAQ",
            createdAt: "2024.08.08",
            isRead: false
        )
    }
}

extension ContentBaseResponse {
    public struct Category: Decodable {
        public let categoryId: Int
        public let categoryName: String
    }
}
