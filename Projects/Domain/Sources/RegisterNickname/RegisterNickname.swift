//
//  RegisterNickname.swift
//  Domain
//
//  Created by 김도형 on 8/1/24.
//

import Foundation

public struct RegisterNickname {
    /// - Response
    public let isDuplicate: Bool
    /// - Request
    public let nickname: String
}
