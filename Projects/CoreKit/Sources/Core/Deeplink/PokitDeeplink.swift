//
//  PokitDeeplink.swift
//  CoreKit
//
//  Created by 김도형 on 2/17/26.
//

import Foundation

import SharedThirdPartyLib

@SchemeRoutable
enum PokitDeeplink: Equatable, Sendable {
    static var scheme: String { "pokit" }
    
    @SchemePattern("shared?categoryId=${categoryId}&contentId=${contentId}&userId=${userId}")
    case shared(categoryId: Int?, contentId: Int?, userId: Int?)

    @SchemePattern("alert")
    case alert
}
