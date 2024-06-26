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
    private let action: () -> Void
    
    public init(
        _ labelText: String,
        state: PokitButtonStyle.State,
        size: PokitButtonStyle.Size,
        action: @escaping () -> Void
    ) {
        self.labelText = labelText
        self.state = state
        self.size = size
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
    
    public func background(
        shape: PokitButtonStyle.Shape
    ) -> some View {
        self
            .pokitButtonBackground(
                state: self.state,
                shape: shape
            )
    }
}

#Preview {
    PokitTextButton("버튼", state: .filled(.primary), size: .medium) {
        
    }
    .background(shape: .round)
}
