//
//  PokitBottomButton.swift
//  DSKit
//
//  Created by 김도형 on 6/29/24.
//

import SwiftUI

public struct PokitBottomButton: View {
    @Binding
    private var isLoading: Bool
    
    private let labelText: String
    private let state: PokitButtonStyle.State
    private let size: PokitButtonStyle.Size = .large
    private let action: () -> Void
    
    public init(
        _ labelText: String,
        state: PokitButtonStyle.State,
        isLoading: Binding<Bool> = .constant(false),
        action: @escaping () -> Void
    ) {
        self.labelText = labelText
        self.state = state
        self._isLoading = isLoading
        self.action = action
    }
    
    public var body: some View {
        Button {
            isLoading = true
            action()
        } label: {
            label
        }
        .disabled(state == .disable)
        .padding(.top, 16)
        .padding(.bottom, 36)
    }
    
    private var label: some View {
        HStack {
            Spacer()
            
            if isLoading {
                PokitSpinner()
                    .frame(width: 48, height: 48)
                    .foregroundStyle(.pokit(.icon(.inverseWh)))
            } else {
                Text(self.labelText)
                    .pokitFont(self.size.font)
                    .foregroundStyle(self.state.textColor)
                    .padding(.vertical, self.size.vPadding)
            }
            
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

