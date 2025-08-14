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
    private let isGradient: Bool
    private let isKeyboardVisible: Bool
    private let action: () -> Void
    
    private init(
        _ labelText: String,
        state: PokitButtonStyle.State,
        isLoading: Binding<Bool>,
        isGradient: Bool,
        isKeyboardVisible: Bool,
        action: @escaping () -> Void
    ) {
        self.labelText = labelText
        self.state = state
        self._isLoading = isLoading
        self.isGradient = isGradient
        self.isKeyboardVisible = isKeyboardVisible
        self.action = action
    }
    
    public init(
        _ labelText: String,
        state: PokitButtonStyle.State,
        action: @escaping () -> Void
    ) {
        self.labelText = labelText
        self.state = state
        self._isLoading = .constant(false)
        self.isGradient = false
        self.isKeyboardVisible = false
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
        .padding(.bottom, isKeyboardVisible ? 10 : 36)
        .background(if: isGradient) {
            LinearGradient(
                stops: [
                    Gradient.Stop(color: .pokit(.bg(.base)).opacity(0), location: 0.00),
                    Gradient.Stop(color: .pokit(.bg(.base)), location: 0.20),
                ],
                startPoint: UnitPoint(x: 0.5, y: 0),
                endPoint: UnitPoint(x: 0.5, y: 1)
            )
        }
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
        .padding(.horizontal, isGradient ? 20 : 0)
        .animation(.pokitDissolve, value: self.state)
    }
    
    public func keyboardAnchor(_ isKeyboardVisible: Bool) -> Self {
        PokitBottomButton(
            self.labelText,
            state: self.state,
            isLoading: self.$isLoading,
            isGradient: self.isGradient,
            isKeyboardVisible: isKeyboardVisible,
            action: self.action
        )
    }
    
    public func gradientBackground() -> Self {
        PokitBottomButton(
            self.labelText,
            state: self.state,
            isLoading: self.$isLoading,
            isGradient: true,
            isKeyboardVisible: self.isKeyboardVisible,
            action: self.action
        )
    }
    
    public func loading(_ isLoading: Binding<Bool>) -> Self {
        PokitBottomButton(
            self.labelText,
            state: self.state,
            isLoading: isLoading,
            isGradient: self.isGradient,
            isKeyboardVisible: self.isKeyboardVisible,
            action: self.action
        )
    }
}

