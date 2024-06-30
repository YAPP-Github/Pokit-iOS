//
//  PokitTextButton.swift
//  DSKit
//
//  Created by 김도형 on 6/26/24.
//

import SwiftUI

public struct PokitTextButton: View {
    private let labelText: String
    private let state: PokitButtonStyle.State
    private let size: PokitButtonStyle.Size
    private let shape: PokitButtonStyle.Shape
    private let action: () -> Void
    
    public init(
        _ labelText: String,
        state: PokitButtonStyle.State,
        size: PokitButtonStyle.Size,
        shape: PokitButtonStyle.Shape,
        action: @escaping () -> Void
    ) {
        self.labelText = labelText
        self.state = state
        self.size = size
        self.shape = shape
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            label
        }
        .disabled(state == .disable)
    }
    
    private var label: some View {
        Text(self.labelText)
            .pokitFont(self.size.font)
            .foregroundStyle(self.state.textColor)
            .padding(.horizontal, self.hPadding)
            .padding(.vertical, self.size.vPadding)
            .background {
                RoundedRectangle(cornerRadius: shape.radius, style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/)
                    .fill(self.state.backgroundColor)
                    .overlay {
                        RoundedRectangle(cornerRadius: shape.radius, style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/)
                            .stroke(self.state.backgroundStrokeColor, lineWidth: 1)
                    }
            }
    }
    
    private var hPadding: CGFloat {
        switch self.size {
        case .small:
            return 12.5
        case .medium:
            return 26
        case .large:
            return 34.5
        }
    }
}
