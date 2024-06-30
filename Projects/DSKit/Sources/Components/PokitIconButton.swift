//
//  PokitIconButton.swift
//  DSKit
//
//  Created by 김도형 on 6/26/24.
//

import SwiftUI

public struct PokitIconButton: View {
    private let labelIcon: PokitImage
    private let state: PokitButtonStyle.State
    private let size: PokitButtonStyle.Size
    private let shape: PokitButtonStyle.Shape
    private let action: () -> Void
    
    public init(
        _ labelIcon: PokitImage,
        state: PokitButtonStyle.State,
        size: PokitButtonStyle.Size,
        shape: PokitButtonStyle.Shape,
        action: @escaping () -> Void
    ) {
        self.labelIcon = labelIcon
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
        Image(self.labelIcon)
            .resizable()
            .frame(width: self.size.iconSize.width, height: self.size.iconSize.height)
            .foregroundStyle(self.state.iconColor)
            .padding(self.size.vPadding)
            .background {
                RoundedRectangle(cornerRadius: shape.radius, style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/)
                    .fill(self.state.backgroundColor)
                    .overlay {
                        RoundedRectangle(cornerRadius: shape.radius, style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/)
                            .stroke(self.state.backgroundStrokeColor, lineWidth: 1)
                    }
            }
    }
}
