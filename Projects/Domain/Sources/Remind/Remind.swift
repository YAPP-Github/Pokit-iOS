//
//  Remind.swift
//  Domain
//
//  Created by 김도형 on 7/31/24.
//

import Foundation

import Util

public struct Remind {
    /// - Response
    public let recommendedList: [BaseContent]
    public let unreadList: [BaseContent]
    public let favoriteList: [BaseContent]
}
