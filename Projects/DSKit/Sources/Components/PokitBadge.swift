//
//  PokitBadge.swift
//  DSKit
//
//  Created by 김도형 on 6/28/24.
//

import SwiftUI

public struct PokitBadge: View {
    private let labelText: String
    private let state: PokitBadge.State
    
    public init(
        _ labelText: String,
        state: PokitBadge.State
    ) {
        self.labelText = labelText
        self.state = state
    }
    
    public var body: some View {
        Text(labelText)
            .pokitFont(.l4)
            .foregroundStyle(
                state == .unCategorized ? .pokit(.text(.secondary)) : .pokit(.text(.tertiary))
            )
            .padding(.horizontal, state == .small ? 4 : 8)
            .padding(.vertical, state == .small ? 2 : 4)
            .background {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(backgroundColor)
                    .overlay {
                        if state == .unRead {
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .stroke(.pokit(.border(.tertiary)), lineWidth: 1)
                        }
                    }
            }
    }
    
    private var backgroundColor: Color {
        switch self.state {
        case .default, .small: return .pokit(.bg(.primary))
        case .unCategorized: return .pokit(.color(.grayScale(._50)))
        case .unRead: return .pokit(.bg(.base))
        }
    }
}

public extension PokitBadge {
    enum State {
        case `default`
        case small
        case unCategorized
        case unRead
    }
}
