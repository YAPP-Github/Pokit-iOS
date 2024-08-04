//
//  CategoryClient.swift
//  CoreKit
//
//  Created by 김민호 on 7/31/24.
//

import Foundation

import Dependencies
import Moya

extension DependencyValues {
    public var categoryClient: CategoryClient {
        get { self[CategoryClient.self] }
        set { self[CategoryClient.self] = newValue }
    }
}
/// Category에 관련한 API를 처리하는 Client
public struct CategoryClient {
    var 카테고리_삭제: @Sendable (
        _ categoryId: String
    ) async throws -> EmptyResponse
    var 카테고리_수정: @Sendable (
        _ categoryId: String,
        _ model: CategoryEditRequest
    ) async throws -> CategoryEditResponse
    var 카테고리_목록_조회: @Sendable (
        _ model: BasePageableRequest
    ) async throws -> CategoryListInquiryResponse
    var 카테고리_생성: @Sendable (
        _ model: CategoryEditRequest
    ) async throws -> CategoryEditResponse
    var 카테고리_프로필_목록_조회: @Sendable (
    ) async throws -> [CategoryImageResponse]
    var 유저_카테고리_개수_조회: @Sendable (
    ) async throws -> CategoryCountResponse
}

extension CategoryClient: DependencyKey {
    public static let liveValue: Self = {
        let provider = MoyaProvider<CategoryEndpoint>.build()

        return Self(
            카테고리_삭제: { id in
                try await provider.request(.카테고리_삭제(categoryId: id))
            },
            카테고리_수정: { id, model in
                try await provider.request(.카테고리_수정(categoryId: id, model: model))
            },
            카테고리_목록_조회: { model in
                try await provider.request(.카테고리_목록_조회(model: model))
            },
            카테고리_생성: { model in
                try await provider.request(.카테고리생성(model: model))
            },
            카테고리_프로필_목록_조회: {
                try await provider.request(.카테고리_프로필_목록_조회)
            },
            유저_카테고리_개수_조회: {
                try await provider.request(.유저_카테고리_개수_조회)
            }
        )
    }()

    public static let previewValue: Self = {
        Self(
            카테고리_삭제: { _ in .init() },
            카테고리_수정: { _, _ in .mock },
            카테고리_목록_조회: { _ in .mock },
            카테고리_생성: { _ in .mock },
            카테고리_프로필_목록_조회: { CategoryImageResponse.mock },
            유저_카테고리_개수_조회: { .mock }
        )
    }()
}