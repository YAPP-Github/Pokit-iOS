//
//  PokitCardItem.swift
//  Util
//
//  Created by 김도형 on 7/11/24.
//

import Foundation

public protocol PokitCardItem {
    var categoryType: String { get }
    var contentSize: Int { get }
    var thumbNail: String { get }
}
