//
//  PokitInputStyle.swift
//  DSKit
//
//  Created by 김도형 on 6/28/24.
//

import SwiftUI

public enum PokitInputStyle: Equatable {
    public enum State: Equatable {
        case `default`
        case input
        case active
        case disable
        case readOnly
        case error(message: String)
        case memo(isReadOnly: Bool)
        
        var infoColor: Color {
            switch self {
            case .disable:
                return .pokit(.text(.disable))
            default:
                return .pokit(.text(.tertiary))
            }
        }
        
        var backgroundColor: Color {
            switch self {
            case .default, .input, .active, .error:
                return .pokit(.bg(.base))
            case .disable:
                return .pokit(.bg(.disable))
            case .readOnly:
                return .pokit(.bg(.secondary))
            case let .memo(isReadOnly):
                return isReadOnly
                ? .pokit(.bg(.primary))
                : Color(red: 1, green: 0.96, blue: 0.89)
            }
        }
        
        var backgroundStrokeColor: Color {
            switch self {
            case .input, .memo:
                return .clear
            case .active:
                return .pokit(.border(.brand))
            case .disable:
                return .pokit(.border(.disable))
            case .readOnly, .default:
                return .pokit(.border(.secondary))
            case .error:
                return .pokit(.border(.error))
            }
        }
        
        var iconColor: Color {
            switch self {
            case .default, .readOnly, .memo:
                return .pokit(.icon(.secondary))
            case .input, .active:
                return .pokit(.icon(.primary))
            case .disable:
                return .pokit(.icon(.disable))
            case .error:
                return .pokit(.icon(.error))
            }
        }
    }
    
    public enum Shape: Equatable {
        case rectangle
        case round
        
        var radius: CGFloat {
            switch self {
            case .rectangle:
                return 8
            case .round:
                return 9999
            }
        }
    }
    
    public enum InputType {
        case text
        case iconR(
            icon: PokitImage,
            action: (() -> Void)? = nil
        )
        case iconL(
            icon: PokitImage,
            action: (() -> Void)? = nil
        )
    }
}
