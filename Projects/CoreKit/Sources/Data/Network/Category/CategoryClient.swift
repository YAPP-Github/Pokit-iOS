//
//  CategoryClient.swift
//  CoreKit
//
//  Created by 김민호 on 7/31/24.
//

import DependenciesMacros

@DependencyClient
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
        _ categoryId: String,
        _ model: BasePageableRequest
    ) async throws -> SharedCategoryResponse
    public var 공유받은_카테고리_저장: @Sendable (
        _ model: CopiedCategoryRequest
    ) async throws -> Void
}

