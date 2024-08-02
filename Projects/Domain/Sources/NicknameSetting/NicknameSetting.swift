//
//  NicknameSetting.swift
//  Domain
//
//  Created by 김도형 on 8/1/24.
//

import Foundation

public struct NicknameSetting {
    // - MARK: Response
    /// 유저 정보
    public let user: BaseUser
    /// 닉네임 중복 여부
    public let isDuplicate: Bool
    // - MARK: Request
    /// 등록할 닉네임
    public let nickname: String
}
