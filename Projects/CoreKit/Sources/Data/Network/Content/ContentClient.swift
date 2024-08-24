//
//  ContentClient.swift
//  CoreKit
//
//  Created by 김민호 on 7/31/24.
//

import Foundation

import Dependencies
import Moya

extension DependencyValues {
    public var contentClient: ContentClient {
        get { self[ContentClient.self] }
        set { self[ContentClient.self] = newValue }
    }
}
/// Category에 관련한 API를 처리하는 Client
public struct ContentClient {
    public var 컨텐츠_삭제: @Sendable (
        _ categoryId: String
    ) async throws -> Void
    public var 컨텐츠_상세_조회: @Sendable (
        _ contentId: String
    ) async throws -> ContentDetailResponse
    public var 컨텐츠_수정: @Sendable (
        _ contentId: String,
        _ model: ContentBaseRequest
    ) async throws -> ContentDetailResponse
    public var 컨텐츠_추가: @Sendable (
        _ model: ContentBaseRequest
    ) async throws -> ContentDetailResponse
    public var 즐겨찾기: @Sendable (
        _ contentId: String
    ) async throws -> BookmarkResponse
    public var 즐겨찾기_취소: @Sendable (
        _ contentId: String
    ) async throws -> Void
    public var 카테고리_내_컨텐츠_목록_조회: @Sendable (
        _ contentId: String,
        _ pageable: BasePageableRequest,
        _ condition: BaseConditionRequest
    ) async throws -> ContentListInquiryResponse
    public var 미분류_카테고리_컨텐츠_조회: @Sendable (
        _ model: BasePageableRequest
    ) async throws -> ContentListInquiryResponse
    public var 컨텐츠_검색: @Sendable (
        _ pageable: BasePageableRequest,
        _ condition: BaseConditionRequest
    ) async throws -> ContentListInquiryResponse
}

extension ContentClient: DependencyKey {
    public static let liveValue: Self = {
        let provider = MoyaProvider<ContentEndpoint>.build()
        
        return Self(
            컨텐츠_삭제: { id in
                try await provider.requestNoBody(.컨텐츠_삭제(contentId: id))
            },
            컨텐츠_상세_조회: { id in
                try await provider.request(.컨텐츠_상세_조회(contentId: id))
            },
            컨텐츠_수정: { id, model in
                try await provider.request(.컨텐츠_수정(contentId: id, model: model))
            },
            컨텐츠_추가: { model in
                try await provider.request(.컨텐츠_추가(model: model))
            },
            즐겨찾기: { id in
                try await provider.request(.즐겨찾기(contentId: id))
            },
            즐겨찾기_취소: { id in
                try await provider.requestNoBody(.즐겨찾기_취소(contentId: id))
            },
            카테고리_내_컨텐츠_목록_조회: { id, pageable, condition in
                try await provider.request(
                    .카태고리_내_컨텐츠_목록_조회(
                        contentId: id,
                        pageable: pageable,
                        condition: condition
                    )
                )
            },
            미분류_카테고리_컨텐츠_조회: { model in
                try await provider.request(.미분류_카테고리_컨텐츠_조회(model: model))
            },
            컨텐츠_검색: { pageable, condition in
                try await provider.request(
                    .컨텐츠_검색(
                        pageable: pageable,
                        condition: condition
                    )
                )
            }
        )
    }()

    public static let previewValue: Self = {
        Self(
            컨텐츠_삭제: { _ in },
            컨텐츠_상세_조회: { _ in .mock },
            컨텐츠_수정: { _, _ in .mock },
            컨텐츠_추가: { _ in .mock },
            즐겨찾기: { _ in .mock },
            즐겨찾기_취소: { _ in },
            카테고리_내_컨텐츠_목록_조회: { _, _, _ in .mock },
            미분류_카테고리_컨텐츠_조회: { _ in .mock },
            컨텐츠_검색: { _, _ in .mock }
        )
    }()
}
