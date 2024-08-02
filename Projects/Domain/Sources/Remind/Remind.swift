//
//  Remind.swift
//  Domain
//
//  Created by 김도형 on 7/31/24.
//

import Foundation

import Util

public struct Remind {
    // - MARK: Response
    /// 오늘의 추천 콘텐츠(링크) 리스트
    public let recommendedList: [BaseContent]
    /// 읽지 않은 콘텐츠(링크) 리스트
    public let unreadList: [BaseContent]
    /// 즐겨찾기한 콘텐츠(링크) 리스트
    public let favoriteList: [BaseContent]
}
