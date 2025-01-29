//
//  ContentClient.swift
//  CoreKit
//
//  Created by 김민호 on 7/31/24.
//

import DependenciesMacros

@DependencyClient
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
    public var 썸네일_수정: @Sendable (
        _ contentId: String,
        _ model: ThumbnailRequest
    ) async throws -> Void
    public var 미분류_링크_포킷_이동: @Sendable (
        _ model: ContentMoveRequest
    ) async throws -> Void
    public var 미분류_링크_삭제: @Sendable (
        _ model: ContentDeleteRequest
    ) async throws -> Void
    public var 추천_컨텐츠_조회: @Sendable (
        _ model: BasePageableRequest
    ) async throws -> ContentListInquiryResponse
}

