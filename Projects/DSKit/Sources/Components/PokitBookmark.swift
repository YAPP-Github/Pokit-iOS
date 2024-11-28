//
//  PokitBookmark.swift
//  DSKit
//
//  Created by 김도형 on 11/28/24.
//

import SwiftUI

public struct PokitBookmark: View {
    private let state: PokitBookmark.State
    private let action: () -> Void
    
    public init(
        state: PokitBookmark.State,
        action: @escaping () -> Void
    ) {
        self.state = state
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            Image(.icon(.starFill))
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundStyle(starColor)
                .padding(4)
                .background {
                    RoundedRectangle(
                        cornerRadius: 9999,
                        style: .continuous
                    )
                    .fill(backgroundColor)
                }
        }
        .disabled(state == .disable)
    }
    
    private var starColor: Color {
        switch state {
        case .default, .disable:
            return .pokit(.icon(.disable))
        case .active:
            return .pokit(.icon(.brand))
        }
    }
    
    private var backgroundColor: Color {
        switch state {
        case .default, .active:
            return .pokit(.bg(.baseIcon))
        case .disable:
            return .pokit(.bg(.disable))
        }
    }
}

extension PokitBookmark {
    public enum State {
        case `default`
        case active
        case disable
    }
}

#Preview {
    PokitBookmark(state: .active) {
        
    }
}
