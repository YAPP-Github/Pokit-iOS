//
//  CategoryClient+LiveKey.swift
//  CoreKit
//
//  Created by 김민호 on 9/30/24.
//

import Foundation

import Dependencies
import Moya

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
            카테고리_목록_조회: { model, categoryFilter, favoriteFilter in
                try await provider.request(
                    .카테고리_목록_조회(
                        model: model,
                        filterUncategorized: categoryFilter,
                        filterFavoriteCategorized: favoriteFilter
                    )
                )
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
            공유받은_카테고리_조회: { id, model in
                try await provider.request(.공유받은_카테고리_조회(categoryId: id, model: model))
            },
            공유받은_카테고리_저장: { model in
                try await provider.requestNoBody(.공유받은_카테고리_저장(model: model))
            }
        )
    }()
}
