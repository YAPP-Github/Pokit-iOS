//
//  ContentClient+TestKey.swift
//  CoreKit
//
//  Created by 김민호 on 9/30/24.
//
import Dependencies

extension ContentClient: TestDependencyKey {
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
            컨텐츠_검색: { _, _ in .mock },
            썸네일_수정: { _, _ in },
            미분류_링크_포킷_이동: { _ in }
        )
    }()
}
