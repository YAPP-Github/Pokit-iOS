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
    public var 카테고리_삭제: @Sendable (_ categoryId: Int) async throws -> Void
    public var 카테고리_수정: @Sendable (
        _ categoryId: Int,
        _ model: CategoryEditRequest
    ) async throws -> CategoryEditResponse
    public var 카테고리_목록_조회: @Sendable (_ model: BasePageableRequest, _ filterUncategorized: Bool) async throws -> CategoryListInquiryResponse
    public var 카테고리_생성: @Sendable (
        _ model: CategoryEditRequest
    ) async throws -> CategoryEditResponse
    public var 카테고리_프로필_목록_조회: @Sendable (
) async throws -> [CategoryImageResponse]
    public var 유저_카테고리_개수_조회: @Sendable (
    ) async throws -> CategoryCountResponse
    public var 카테고리_상세_조회: @Sendable (
        _ categoryId: String
    ) async throws -> CategoryEditResponse
    public var 공유받은_카테고리_조회: @Sendable (
        _ categoryId: String
    ) async throws -> SharedCategoryResponse
    public var 공유받은_카테고리_저장: @Sendable (
        _ model: CopiedCategoryRequest
    ) async throws -> Void
}

extension CategoryClient: DependencyKey {
    public static let liveValue: Self = {
        let provider = MoyaProvider<CategoryEndpoint>.build()

        return Self(
            카테고리_삭제: { id in
                try await provider.requestNoBody(.카테고리_삭제(categoryId: id))
            },
            카테고리_수정: { id, model in
                try await provider.request(.카테고리_수정(categoryId: id, model: model))
            },
            카테고리_목록_조회: { model, categoryFilter in
                try await provider.request(.카테고리_목록_조회(model: model, filterUncategorized: categoryFilter))
            },
            카테고리_생성: { model in
                try await provider.request(.카테고리생성(model: model))
            },
            카테고리_프로필_목록_조회: {
                try await provider.request(.카테고리_프로필_목록_조회)
            },
            유저_카테고리_개수_조회: {
                try await provider.request(.유저_카테고리_개수_조회)
            },
            카테고리_상세_조회: { id in
                try await provider.request(.카테고리_상세_조회(categoryId: id))
            },
            공유받은_카테고리_조회: { id in
                try await provider.request(.공유받은_카테고리_조회(categoryId: id))
            },
            공유받은_카테고리_저장: { model in
                try await provider.requestNoBody(.공유받은_카테고리_저장(model: model))
            }
        )
    }()

    public static let previewValue: Self = {
        Self(
            카테고리_삭제: { _ in },
            카테고리_수정: { _, _ in .mock },
            카테고리_목록_조회: { _, _ in .mock },
            카테고리_생성: { _ in .mock },
            카테고리_프로필_목록_조회: { CategoryImageResponse.mock },
            유저_카테고리_개수_조회: { .mock },
            카테고리_상세_조회: { _ in .mock },
            공유받은_카테고리_조회: { _ in .mock },
            공유받은_카테고리_저장: { _ in }
        )
    }()
}
