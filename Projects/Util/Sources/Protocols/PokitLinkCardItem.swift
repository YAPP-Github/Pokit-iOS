//
//  PokitLinkCardItem.swift
//  Util
//
//  Created by 김도형 on 7/11/24.
//

import Foundation

public protocol PokitLinkCardItem {
    var title: String { get }
    var thumbNail: String { get }
    var createdAt: Date { get }
    var categoryName: String { get }
    var isRead: Bool { get }
    var data: String { get }
}
