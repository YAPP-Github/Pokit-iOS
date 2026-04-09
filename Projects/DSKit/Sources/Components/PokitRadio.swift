//
//  PokitRadio.swift
//  DSKit
//
//  Created by Codex on 4/6/26.
//

import SwiftUI

public struct PokitRadio: View {
    private let state: RadioState

    public init(state: RadioState) {
        self.state = state
    }

    public var body: some View {
        Circle()
            .fill(state.backgroundColor)
            .overlay {
                Circle()
                    .stroke(state.borderColor, lineWidth: 2)
            }
            .overlay {
                Circle()
                    .fill(state.innerColor)
                    .frame(width: 14, height: 14)
            }
            .frame(width: 24, height: 24)
            .animation(.pokitDissolve, value: state)
    }
}

public extension PokitRadio {
    enum RadioState: Equatable {
        case `default`
        case active
        case disable

        var backgroundColor: Color {
            switch self {
            case .default, .active:
                return .pokit(.bg(.base))
            case .disable:
                return .pokit(.bg(.disable))
            }
        }

        var borderColor: Color {
            switch self {
            case .default:
                return .pokit(.border(.tertiary))
            case .active:
                return .pokit(.border(.brand))
            case .disable:
                return .pokit(.border(.disable))
            }
        }

        var innerColor: Color {
            switch self {
            case .default:
                return .pokit(.icon(.tertiary))
            case .active:
                return .pokit(.bg(.brand))
            case .disable:
                return .pokit(.icon(.secondary))
            }
        }
    }
}

#Preview {
    HStack(spacing: 12) {
        PokitRadio(state: .default)
        PokitRadio(state: .active)
        PokitRadio(state: .disable)
    }
    .padding()
    .background(.pokit(.bg(.base)))
}
