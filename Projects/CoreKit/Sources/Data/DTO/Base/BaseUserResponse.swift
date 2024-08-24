//
//  BaseUserResponse.swift
//  CoreKit
//
//  Created by 김민호 on 7/31/24.
//

import Foundation
/// 닉네임 수정, 회원등록 API Response 공통
public struct BaseUserResponse: Decodable {
    public let id: Int
    public let email: String
    public let nickname: String
}

extension BaseUserResponse {
    public static var mock: Self = Self(
        id: 961222,
        email: "abcd@naver.com",
        nickname: "뽀삐1"
    )
}
