//
//  CategoryClient+TestKey.swift
//  CoreKit
//
//  Created by 김민호 on 9/30/24.
//

import Dependencies

extension CategoryClient: TestDependencyKey {
    public static let previewValue: Self = {
        Self(
            카테고리_삭제: { _ in },
            카테고리_수정: { _, _ in .mock },
            카테고리_목록_조회: { _, _ in .mock },
            카테고리_생성: { _ in .mock },
            카테고리_프로필_목록_조회: { CategoryImageResponse.mock },
            유저_카테고리_개수_조회: { .mock },
            카테고리_상세_조회: { _ in .mock },
            공유받은_카테고리_조회: { _, _ in .mock },
            공유받은_카테고리_저장: { _ in }
        )
    }()
}
