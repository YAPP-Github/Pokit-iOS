//
//  RemindClient+TestKey.swift
//  CoreKit
//
//  Created by 김민호 on 9/30/24.
//

import Dependencies

extension RemindClient: TestDependencyKey {
    public static let previewValue: Self = {
        .init(
            오늘의_리마인드_조회: { [.mock(id: 0), .mock(id: 1), .mock(id: 2)]},
            읽지않음_컨텐츠_조회: { _ in .mock },
            즐겨찾기_링크모음_조회: { _ in .mock },
            읽지않음_컨텐츠_개수_조회: { .mock },
            즐겨찾기_컨텐츠_개수_조회: { .mock }
        )
    }()
}
