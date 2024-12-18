//
//  PokitIconRButton.swift
//  DSKit
//
//  Created by 김도형 on 6/26/24.
//

import SwiftUI

public struct PokitIconRButton: View {
    private let labelText: String
    private let labelIcon: PokitImage
    private let state: PokitButtonStyle.State
    private let size: PokitButtonStyle.Size
    private let shape: PokitButtonStyle.Shape
    private let action: () -> Void
    
    public init(
        _ labelText: String,
        _ labelIcon: PokitImage,
        state: PokitButtonStyle.State,
        size: PokitButtonStyle.Size,
        shape: PokitButtonStyle.Shape,
        action: @escaping () -> Void
    ) {
        self.labelText = labelText
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
        HStack(spacing: self.size.spacing) {
            Text(self.labelText)
                .pokitFont(self.size.font)
                .foregroundStyle(self.state.textColor)
            
            
            Image(self.labelIcon)
                .resizable()
                .frame(width: self.size.iconSize.width, height: self.size.iconSize.height)
                .foregroundStyle(self.state.iconColor)
        }
        .padding(.leading, self.size.hPadding + 4)
        .padding(.trailing, self.size.hPadding)
        .padding(.vertical, self.size.vPadding)
        .background {
            RoundedRectangle(cornerRadius: shape.radius(size: self.size), style: .continuous)
                .fill(self.state.backgroundColor)
                .overlay {
                    RoundedRectangle(cornerRadius: shape.radius(size: self.size), style: .continuous)
                        .stroke(self.state.backgroundStrokeColor, lineWidth: 1)
                }
        }
        .frame(minWidth: self.size.minWidth)
    }
}
