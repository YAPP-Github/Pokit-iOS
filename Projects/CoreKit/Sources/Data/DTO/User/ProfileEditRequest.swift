//
//  ProfileEditRequest.swift
//  CoreKit
//
//  Created by 김민호 on 2/25/25.
//

import Foundation
/// 프로필 수정 API Request
public struct ProfileEditRequest: Encodable {
    public let profileImageId: Int?
    public let nickname: String
    
    public init(profileImageId: Int?, nickname: String) {
        self.profileImageId = profileImageId
        self.nickname = nickname
    }
}

extension ProfileEditRequest {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(profileImageId, forKey: .profileImageId)
        try container.encode(nickname, forKey: .nickname)
        
        if profileImageId == nil {
            try container.encodeNil(forKey: .profileImageId)
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case profileImageId
        case nickname
    }
}
