//
//  SocialLoginClient+TestKey.swift
//  CoreKit
//
//  Created by 김민호 on 9/30/24.
//

import Foundation

import Dependencies

extension SocialLoginClient: TestDependencyKey {
    public static let testValue = Self()
    public static let previewValue: Self = {
        Self(
            appleLogin: { .appleMock },
            googleLogin: { .googleMock },
            getClientSceret: { "" }
        )
    }()
}
