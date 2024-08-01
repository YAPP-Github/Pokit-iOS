//
//  SignUpDone.swift
//  Domain
//
//  Created by 김도형 on 8/1/24.
//

import Foundation

public struct SignUpDone {
    /// - Response
    public let user: BaseUser
    /// - Request
    public let interest: [String]
}
