//
//  PokitButton.swift
//  DSKit
//
//  Created by 김도형 on 6/22/24.
//

import SwiftUI

public struct PokitButtonLabel: View {
    private let text: String?
    private let icon: PokitImage?
    private let state: Bool = true
    private let category: Self.Category
    private let style: Self.Style
    private let type: Self.ButtonType
    private let shape: Self.Shape
    private let size: Self.Size
    
    private let action: () -> Void
    
    public init(
        text: String? = nil,
        icon: PokitImage? = nil,
        category: Self.Category = .iconL,
        style: Self.Style = .filled,
        type: Self.ButtonType = .primary,
        shape: Self.Shape = .rectangle,
        size: Self.Size = .small,
        action: @escaping () -> Void
    ) {
        self.text = text
        self.icon = icon
        self.category = category
        self.style = style
        self.type = type
        self.shape = shape
        self.size = size
        self.action = action
    }
    
    public var body: some View {
        Button(action: self.action) {
            self.label
        }
    }
    
    private var label: some View {
        Group {
            switch category {
            case .iconL:
                HStack(spacing: self.spacing) {
                    iconLabel
                    
                    textLabel
                }
            case .iconR:
                HStack(spacing: self.spacing) {
                    textLabel
                    
                    iconLabel
                    
                }
            case .textOnly:
                textLabel
            case .iconOnly:
                iconLabel
            }
        }
        .padding(.leading, lPadding)
        .padding(.trailing, tPadding)
        .padding(.vertical, vPadding)
        .background {
            background
        }
    }
    
    private var textLabel: some View {
        Text(self.text ?? "")
            .pokitFont(self.font)
            .foregroundStyle(textColor)
    }
    
    private var iconLabel: some View {
        Group {
            if let icon {
                Image(icon)
                    .resizable()
                    .renderingMode(.template)
            } else {
                Image(systemName: "questionmark")
                    .resizable()
                    .renderingMode(.template)
            }
        }
        .frame(width: iconSize.width, height: iconSize.height)
        .foregroundStyle(iconColor)
    }
    
    private var background: some View {
        RoundedRectangle(cornerRadius: radius, style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/)
            .fill(backgroundColor)
            .overlay {
                RoundedRectangle(cornerRadius: radius, style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/)
                    .stroke(strokeColor, lineWidth: 1)
            }
    }
    
    private var spacing: CGFloat {
        switch self.size {
        case .small:
            return 4
        case .medium:
            return 8
        case .large:
            return 12
        }
    }
    
    private var font: PokitFont {
        switch self.size {
        case .small:
            return .l3(.r)
        case .medium:
            return .l2(.r)
        case .large:
            return .l1(.b)
        }
    }
    
    private var iconSize: CGSize {
        switch self.size {
        case .small:
            return .init(width: 16, height: 16)
        case .medium:
            return .init(width: 20, height: 20)
        case .large:
            return .init(width: 24, height: 24)
        }
    }
    
    private var hPadding: CGFloat {
        switch self.size {
        case .small:
            return 8
        case .medium:
            return 16
        case .large:
            return 20
        }
    }
    
    private var lPadding: CGFloat {
        switch self.size {
        case .small:
            switch self.category {
            case .iconL: return 8
            case .iconR: return 12
            case .textOnly: return 12.5
            case .iconOnly: return 8
            }
        case .medium:
            switch self.category {
            case .iconL: return 16
            case .iconR: return 20
            case .textOnly: return 26
            case .iconOnly: return 10
            }
        case .large:
            switch self.category {
            case .iconL: return 20
            case .iconR: return 24
            case .textOnly: return 34.5
            case .iconOnly: return 13
            }
        }
    }
    
    private var tPadding: CGFloat {
        switch self.size {
        case .small:
            switch self.category {
            case .iconL: return 12
            case .iconR: return 8
            case .textOnly: return 12.5
            case .iconOnly: return 8
            }
        case .medium:
            switch self.category {
            case .iconL: return 20
            case .iconR: return 16
            case .textOnly: return 26
            case .iconOnly: return 10
            }
        case .large:
            switch self.category {
            case .iconL: return 24
            case .iconR: return 20
            case .textOnly: return 34.5
            case .iconOnly: return 13
            }
        }
    }
    
    private var vPadding: CGFloat {
        switch self.size {
        case .small: return 8
        case .medium: return 10
        case .large: return 13
        }
    }
    
    private var iconColor: Color {
        if state {
            switch self.style {
            case .filled: return .pokit(.icon(.inverseWh))
            case .stroke: return .pokit(.icon(.primary))
            }
        } else {
            return .pokit(.icon(.disable))
        }
    }
    
    private var textColor: Color {
        if state {
            switch self.style {
            case .filled: return .pokit(.text(.inverseWh))
            case .stroke: return .pokit(.text(.primary))
            }
        } else {
            return .pokit(.text(.disable))
        }
    }
    
    private var backgroundColor: Color {
        if state {
            switch self.style {
            case .filled:
                switch self.type {
                case .primary: return .pokit(.bg(.brand))
                case .secondary: return .pokit(.bg(.tertiary))
                }
            case .stroke: return .pokit(.bg(.base))
            }
        } else {
            return .pokit(.bg(.disable))
        }
    }
    
    private var strokeColor: Color {
        if state {
            switch self.type {
            case .primary: return .pokit(.border(.brand))
            case .secondary: return .pokit(.border(.secondary))
            }
        } else {
            return .pokit(.border(.disable))
        }
    }
    
    private var radius: CGFloat {
        switch self.shape {
        case .rectangle: return 4
        case .round: return 9999
        }
    }
}

public extension PokitButtonLabel {
    enum Category {
        case iconL
        case iconR
        case textOnly
        case iconOnly
    }
    
    enum Style {
        case stroke
        case filled
    }
    
    enum ButtonType {
        case primary
        case secondary
    }
    
    enum Size {
        case small
        case medium
        case large
    }
    
    enum Shape {
        case rectangle
        case round
    }
}

#Preview {
    PokitButtonLabel(text: "버튼", icon: .icon(.search), style: .stroke) {
        
    }
}
