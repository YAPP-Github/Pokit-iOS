//
//  ShapeStyle+Extension.swift
//  DSKit
//
//  Created by 김도형 on 6/22/24.
//

import SwiftUI

public extension ShapeStyle where Self == Color {
    static func pokit(_ pokitColor: PokitColor) -> Color {
        return .pokit(pokitColor)
    }
}
