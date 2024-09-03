//
//  PokitButtonStyle.swift
//  DSKit
//
//  Created by 김도형 on 6/26/24.
//

import SwiftUI

public enum PokitButtonStyle {
    public enum State: Equatable {
        case `default`(PokitButtonStyle.ButtonType)
        case stroke(PokitButtonStyle.ButtonType)
        case filled(PokitButtonStyle.ButtonType)
        case disable
    }
    
    public enum ButtonType: Equatable {
        case primary
        case secondary
    }
    
    public enum Size {
        case small
        case medium
        case large
    }
    
    public enum Shape {
        case rectangle
        case round
    }
}

extension PokitButtonStyle.State {
    var backgroundColor: Color {
        switch self {
        case .default, .stroke(_): return .pokit(.bg(.base))
        case .filled(let type):
            switch type {
            case .primary: return .pokit(.bg(.brand))
            case .secondary: return .pokit(.bg(.tertiary))
            }
        case .disable:
            return .pokit(.bg(.disable))
        }
    }
    
    var backgroundStrokeColor: Color {
        switch self {
        case .default: return .pokit(.border(.secondary))
        case .filled(let type), .stroke(let type):
            switch type {
            case .primary: return .pokit(.border(.brand))
            case .secondary: return .pokit(.border(.secondary))
            }
        case .disable:
            return .pokit(.border(.disable))
        }
    }
    
    var iconColor: Color {
        switch self {
        case .default: return .pokit(.icon(.disable))
        case .stroke(_): return .pokit(.icon(.primary))
        case .filled(_): return .pokit(.icon(.inverseWh))
        case .disable: return .pokit(.icon(.disable))
        }
    }
    
    var textColor: Color {
        switch self {
        case .default: return .pokit(.text(.tertiary))
        case .stroke(_): return .pokit(.text(.primary))
        case .filled(_): return .pokit(.text(.inverseWh))
        case .disable: return .pokit(.text(.disable))
        }
    }
}

extension PokitButtonStyle.ButtonType {
    var color: Color {
        switch self {
        case .primary: return .pokit(.bg(.brand))
        case .secondary: return .pokit(.bg(.tertiary))
        }
    }
}

extension PokitButtonStyle.Size {
    var spacing: CGFloat {
        switch self {
        case .small:
            return 4
        case .medium:
            return 8
        case .large:
            return 12
        }
    }
    
    var iconSize: CGSize {
        switch self {
        case .small:
            return .init(width: 16, height: 16)
        case .medium:
            return .init(width: 20, height: 20)
        case .large:
            return .init(width: 24, height: 24)
        }
    }
    
    var font: PokitFont {
        switch self {
        case .small:
            return .l3(.r)
        case .medium:
            return .l2(.r)
        case .large:
            return .l1(.b)
        }
    }
    
    var vPadding: CGFloat {
        switch self {
        case .small: return 8
        case .medium: return 10
        case .large: return 13
        }
    }
}

extension PokitButtonStyle.Shape {
    func radius(size: PokitButtonStyle.Size) -> CGFloat {
        switch self {
        case .rectangle: return size == .small ? 4 : 8
        case .round: return 9999
        }
    }
}
