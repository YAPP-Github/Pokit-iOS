//
//  PokitIconRChip.swift
//  DSKit
//
//  Created by 김도형 on 6/28/24.
//

import SwiftUI

public struct PokitIconRChip: View {
    private let labelText: String
    private let state: PokitButtonStyle.State
    private let size: PokitChipStyle.Size
    private let action: (() -> Void)?
    
    public init(
        _ labelText: String,
        state: PokitButtonStyle.State,
        size: PokitChipStyle.Size,
        action: (() -> Void)? = nil
    ) {
        self.labelText = labelText
        self.state = state
        self.size = size
        self.action = action
    }
    
    public var body: some View {
        Button(action: { action?() }) {
            label
        }
        .disabled(state == .disable)
    }
    
    private var label: some View {
        HStack(spacing: self.spacing) {
            Text(self.labelText)
                .pokitFont(self.font)
                .foregroundStyle(self.state.textColor)
            
            
            Image(.icon(.x))
                .resizable()
                .frame(width: self.iconSize.width, height: self.iconSize.height)
                .foregroundStyle(self.state.iconColor)
        }
        .padding(.leading, self.lPadding)
        .padding(.trailing, self.tPadding)
        .padding(.vertical, self.vPadding)
        .background {
            RoundedRectangle(cornerRadius: 9999, style: .continuous)
                .fill(self.state.backgroundColor)
                .overlay {
                    RoundedRectangle(cornerRadius: 9999, style: .continuous)
                        .stroke(self.state.backgroundStrokeColor, lineWidth: 1)
                }
        }
    }
    
    private var spacing: CGFloat {
        switch self.size {
        case .small: return 4
        case .medium: return 0
        }
    }
    
    private var lPadding: CGFloat {
        switch self.size {
        case .small: return 12
        case .medium: return 16
        }
    }
    
    private var tPadding: CGFloat {
        switch self.size {
        case .small: return 8
        case .medium: return 12
        }
    }
    
    private var hPadding: CGFloat {
        switch self.size {
        case .small: return 8
        case .medium: return 16
        }
    }
    
    private var vPadding: CGFloat {
        switch self.size {
        case .small: return 8
        case .medium: return 10
        }
    }
    
    private var font: PokitFont {
        switch self.size {
        case .small: return .l3(.r)
        case .medium: return .l2(.r)
        }
    }
    
    private var iconSize: CGSize {
        switch self.size {
        case .small:
            return .init(width: 16, height: 16)
        case .medium:
            return .init(width: 22, height: 22)
        }
    }
}
