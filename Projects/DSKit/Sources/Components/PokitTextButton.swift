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
            .padding(.horizontal, self.size.hPadding)
            .padding(.vertical, self.size.vPadding)
            .frame(minWidth: self.size.minWidth)
            .background {
                RoundedRectangle(cornerRadius: shape.radius(size: self.size), style: .continuous)
                    .fill(self.state.backgroundColor)
                    .overlay {
                        RoundedRectangle(cornerRadius: shape.radius(size: self.size), style: .continuous)
                            .stroke(self.state.backgroundStrokeColor, lineWidth: 1)
                    }
            }
    }
}
