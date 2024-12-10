//
//  PokitBadge.swift
//  DSKit
//
//  Created by 김도형 on 6/28/24.
//

import SwiftUI

public struct PokitBadge: View {
    private let state: PokitBadge.State
    
    public init(state: PokitBadge.State) {
        self.state = state
    }
    
    public var body: some View {
        label
            .background {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(backgroundColor)
            }
    }
    
    private var backgroundColor: Color {
        switch self.state {
        case .default, .small, .memo, .member: return .pokit(.bg(.primary))
        case .unCategorized: return .pokit(.color(.grayScale(._50)))
        case .unRead: return Color(red: 1, green: 0.95, blue: 0.92)
        }
    }
    
    private var labelColor: Color {
        switch self.state {
        case .default, .small: return .pokit(.text(.tertiary))
        case .unCategorized: return .pokit(.text(.secondary))
        case .unRead: return .pokit(.text(.brand))
        case .memo, .member: return .pokit(.icon(.secondary))
        }
    }
    
    private var label: some View {
        Group {
            switch self.state {
            case let .default(labelText):
                Text(labelText)
                    .pokitFont(.l4)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
            case let .small(labelText):
                Text(labelText)
                    .pokitFont(.l4)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
            case .unCategorized:
                Text("미분류")
                    .pokitFont(.l4)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
            case .unRead:
                Text("안읽음")
                    .pokitFont(.l4)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
            case .memo:
                Image(.icon(.memo))
                    .resizable()
                    .frame(width: 16, height: 16)
                    .padding(2)
            case .member:
                Image(.icon(.member))
                    .resizable()
                    .frame(width: 16, height: 16)
                    .padding(2)
            }
        }
        .foregroundStyle(labelColor)
    }
}

public extension PokitBadge {
    enum State: Equatable {
        case `default`(String)
        case small(String)
        case unCategorized
        case unRead
        case memo
        case member
    }
}

#Preview {
    PokitBadge(state: .unRead)
    
    PokitBadge(state: .default("포킷명"))
    
    PokitBadge(state: .unCategorized)
    
    PokitBadge(state: .memo)
    
    PokitBadge(state: .member)
}
