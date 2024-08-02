//
//  RegisterNickname.swift
//  Domain
//
//  Created by 김도형 on 8/1/24.
//

import Foundation

public struct RegisterNickname {
    // - MARK: Response
    /// 닉네임 중복 여부
    public let isDuplicate: Bool
    // - MARK: Request
    /// 등록할 닉네임
    public let nickname: String
}
