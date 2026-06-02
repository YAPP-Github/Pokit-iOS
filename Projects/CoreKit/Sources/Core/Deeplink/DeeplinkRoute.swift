//
//  DeeplinkRoute.swift
//  CoreKit
//
//  Created by 김도형 on 2/17/26.
//

import Foundation

public enum DeeplinkRoute: Equatable, Sendable {
    case kakaoSharedCategory(categoryId: Int, shareType: String?)
    case pokitShared(categoryId: Int?, contentId: Int?, userId: Int?)
    case pokitAlert
}
