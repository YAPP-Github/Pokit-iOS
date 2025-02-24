//
//  BaseUser.swift
//  Domain
//
//  Created by 김도형 on 8/1/24.
//

import Foundation

public struct BaseUser: Equatable {
    public let id: Int
    public let email: String
    public let nickname: String
    public let profile: BaseProfile?
}
