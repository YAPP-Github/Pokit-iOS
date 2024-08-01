//
//  SignUpDone.swift
//  Domain
//
//  Created by 김도형 on 8/1/24.
//

import Foundation

public struct SignUpDone {
    // - MARK: Response
    /// 유저 정보
    public let user: BaseUser
    // - MARK: Request
    /// 등록할 닉네임
    public let nickname: String
    /// - 등록할 유저 관심사
    public let interest: [String]
}
