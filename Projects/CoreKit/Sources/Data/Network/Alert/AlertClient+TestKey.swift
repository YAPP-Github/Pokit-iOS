//
//  AlertClient+TestKey.swift
//  CoreKit
//
//  Created by 김민호 on 9/30/24.
//

import Foundation

import Dependencies
import Moya

extension AlertClient: TestDependencyKey {
    public static let previewValue: Self = {
        Self(
            알람_목록_조회: { _ in .mock },
            알람_삭제: { _ in }
        )
    }()
}
