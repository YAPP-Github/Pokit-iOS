//
//  PokitColor.swift
//  DSKit
//
//  Created by 김도형 on 6/22/24.
//

import SwiftUI

public enum PokitColor {
    case color(Self.Color)
    case text(Self.Text)
    case icon(Self.Icon)
    case bg(Self.BG)
    case border(Self.Border)
}

public extension PokitColor {
    enum Color {
        case blue(Self.Scale)
        case green(Self.Scale)
        case orange(Self.Scale)
        case red(Self.Scale)
        case yellow(Self.Scale)
        case grayScale(Self.Scale)
        
        public enum Scale {
            case white
            case _50
            case _100
            case _200
            case _300
            case _400
            case _500
            case _600
            case _700
            case _800
            case _900
        }
    }
}

public extension PokitColor {
    enum Text {
        case brand
        case disable
        case error
        case info
        case inverseWh
        case primary
        case secondary
        case success
        case tertiary
        case warning
    }
}

public extension PokitColor {
    enum Icon {
        case brand
        case disable
        case error
        case info
        case inverseWh
        case primary
        case secondary
        case success
        case tertiary
        case warning
    }
}

public extension PokitColor {
    enum BG {
        case base
        case baseIcon
        case brand
        case disable
        case error
        case info
        case primary
        case secondary
        case success
        case tertiary
        case warning
    }
}

public extension PokitColor {
    enum Border {
        case brand
        case disable
        case error
        case info
        case inverseWh
        case primary
        case secondary
        case success
        case tertiary
        case warning
    }
}
