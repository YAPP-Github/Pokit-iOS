//
//  PokitLinkCardItem.swift
//  Util
//
//  Created by 김도형 on 7/11/24.
//

import Foundation

public protocol PokitLinkCardItem {
    var title: String { get }
    var memo: String? { get }
    var thumbNail: String { get }
    var createdAt: String { get }
    var categoryName: String { get }
    var isRead: Bool? { get }
    var data: String { get }
    var domain: String { get }
    var isFavorite: Bool? { get }
}
