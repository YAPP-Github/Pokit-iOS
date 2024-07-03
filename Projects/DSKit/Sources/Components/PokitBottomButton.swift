//
//  PokitBottomButton.swift
//  DSKit
//
//  Created by 김도형 on 6/29/24.
//

import SwiftUI

public struct PokitBottomButton: View {
    private let labelText: String
    private let state: PokitButtonStyle.State
    private let size: PokitButtonStyle.Size = .large
    private let action: () -> Void
    
    public init(
        _ labelText: String,
        state: PokitButtonStyle.State,
        action: @escaping () -> Void
    ) {
        self.labelText = labelText
        self.state = state
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            label
        }
        .disabled(state == .disable)
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 28)
        .background(.pokit(.bg(.base)))
    }
    
    private var label: some View {
        HStack {
            Spacer()
            
            Text(self.labelText)
                .pokitFont(self.size.font)
                .foregroundStyle(self.state.textColor)
                .padding(.vertical, self.size.vPadding)
            
            Spacer()
        }
        .background {
            RoundedRectangle(
                cornerRadius: PokitButtonStyle.Shape.rectangle.radius(size: self.size),
                style: .continuous
            )
            .fill(self.state.backgroundColor)
            .overlay {
                RoundedRectangle(
                    cornerRadius: PokitButtonStyle.Shape.rectangle.radius(size: self.size),
                    style: .continuous
                )
                .stroke(self.state.backgroundStrokeColor, lineWidth: 1)
            }
        }
        .animation(.smooth, value: self.state)
    }
}

