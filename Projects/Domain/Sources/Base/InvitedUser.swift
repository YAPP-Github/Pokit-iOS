//
//  InvitedUser.swift
//  Domain
//
//  Created by 김도형 on 12/25/25.
//

import Foundation

public struct InvitedUser: Equatable, Identifiable {
    public let id: Int
    public let nickname: String
    public let profile: BaseProfile?
    
    public init(id: Int, nickname: String, profile: BaseProfile?) {
        self.id = id
        self.nickname = nickname
        self.profile = profile
    }
}
