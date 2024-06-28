//
//  PokitIconLButton.swift
//  DSKit
//
//  Created by 김도형 on 6/26/24.
//

import SwiftUI

public struct PokitIconLButton: View {
    private let labelText: String
    private let labelIcon: PokitImage
    private let state: PokitButtonStyle.State
    private let size: PokitButtonStyle.Size
    private let action: () -> Void
    
    public init(
        _ labelText: String,
        _ labelIcon: PokitImage,
        state: PokitButtonStyle.State,
        size: PokitButtonStyle.Size,
        action: @escaping () -> Void
    ) {
        self.labelText = labelText
        self.labelIcon = labelIcon
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
        HStack(spacing: self.size.spacing) {
            Image(self.labelIcon)
                .resizable()
                .frame(width: self.size.iconSize.width, height: self.size.iconSize.height)
                .foregroundStyle(self.state.iconColor)
            
            Text(self.labelText)
                .pokitFont(self.size.font)
                .foregroundStyle(self.state.textColor)
        }
        .padding(.leading, self.lPadding)
        .padding(.trailing, self.tPadding)
        .padding(.vertical, self.size.vPadding)
    }
    
    private var lPadding: CGFloat {
        switch self.size {
        case .small:
            return 8
        case .medium:
            return 16
        case .large:
            return 20
        }
    }
    
    private var tPadding: CGFloat {
        switch self.size {
        case .small:
            return 12
        case .medium:
            return 20
        case .large:
            return 24
        }
    }
    
    public func background(
        shape: PokitButtonStyle.Shape
    ) -> some View {
        self
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

#Preview {
    PokitIconLButton(
        "버튼",
        .icon(.search),
        state: .filled(.primary),
        size: .medium
    ) {
        
        VStack {
            PokitIconLButton("버튼", .icon(.search), state: .default, size: .large) {
                
            }
            .background(shape: .rectangle)
            
            PokitIconLButton("버튼", .icon(.search), state: .filled(.primary), size: .large) {
                
            }
            .background(shape: .rectangle)
            
            PokitIconLButton("버튼", .icon(.search), state: .filled(.secondary), size: .large) {
                
            }
            .background(shape: .rectangle)
            
            PokitIconLButton("버튼", .icon(.search), state: .stroke(.primary), size: .large) {
                
            }
            .background(shape: .rectangle)
            
            PokitIconLButton("버튼", .icon(.search), state: .stroke(.secondary), size: .large) {
                
            }
            .background(shape: .rectangle)
            
            PokitIconLButton("버튼", .icon(.search), state: .disable, size: .large) {
                
            }
            .background(shape: .rectangle)
            
            PokitIconLButton("버튼", .icon(.search), state: .default, size: .large) {
                
            }
            .background(shape: .round)
            
            PokitIconLButton("버튼", .icon(.search), state: .filled(.primary), size: .large) {
                
            }
            .background(shape: .round)
            
            PokitIconLButton("버튼", .icon(.search), state: .filled(.secondary), size: .large) {
                
            }
            .background(shape: .round)
            
            PokitIconLButton("버튼", .icon(.search), state: .stroke(.primary), size: .large) {
                
            }
            .background(shape: .round)
            
            PokitIconLButton("버튼", .icon(.search), state: .stroke(.secondary), size: .large) {
                
            }
            .background(shape: .round)
            
            PokitIconLButton("버튼", .icon(.search), state: .disable, size: .large) {
                
            }
            .background(shape: .round)
        }
    }
}
