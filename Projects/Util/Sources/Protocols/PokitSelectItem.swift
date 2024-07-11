//
//  PokitSelectItem.swift
//  Util
//
//  Created by 김도형 on 7/11/24.
//

import Foundation

public protocol PokitSelectItem: Identifiable, Equatable {
    var categoryType: String { get }
    var contentSize: Int { get }
}
