//
//  NicknameSetting.swift
//  Domain
//
//  Created by 김도형 on 8/1/24.
//

import Foundation

public struct NicknameSetting: Equatable {
    // - MARK: Response
    /// 유저 정보
    public var user: BaseUser? = nil
    /// 닉네임 중복 여부
    public var isDuplicate: Bool
    /// 유저 선택 프로필
    public var selectedProfile: BaseProfile?
    /// 프로필에 설정할 수 있는 이미지
    public var imageList: [BaseProfile]
    
    // - MARK: Request
    /// 등록할 닉네임
    public var nickname: String
    
    public init(
        isDuplicate: Bool = false,
        nickname: String = "",
        selectedProfile: BaseProfile?
    ) {
        self.imageList = []
        self.isDuplicate = isDuplicate
        self.nickname = nickname
        self.selectedProfile = selectedProfile
    }
}
