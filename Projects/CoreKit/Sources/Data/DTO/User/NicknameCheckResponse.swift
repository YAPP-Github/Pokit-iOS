//
//  NicknameCheckResponse.swift
//  CoreKit
//
//  Created by 김민호 on 7/31/24.
//

import Foundation
/// 닉네임 중복 체크 API Response
public struct NicknameCheckResponse: Decodable {
    public let isDuplicate: Bool
}
extension NicknameCheckResponse {
    public static var mock: Self = Self(isDuplicate: false)
}
