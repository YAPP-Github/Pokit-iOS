//
//  PokitButton.swift
//  DSKit
//
//  Created by 김도형 on 6/22/24.
//

import SwiftUI

public struct PokitButton: View {
    private let text: String?
    private let icon: PokitImage?
    private let isDisable: Bool
    private let category: Self.Category
    private let state: Self.Style
    private let type: Self.ButtonType
    private let shape: Self.Shape
    private let size: Self.Size
    
    private let action: () -> Void
    
    public init(
        text: String? = nil,
        icon: PokitImage? = nil,
        isDisable: Bool = false,
        category: Self.Category = .iconL,
        state: Self.Style = .default,
        type: Self.ButtonType = .primary,
        shape: Self.Shape = .rectangle,
        size: Self.Size = .small,
        action: @escaping () -> Void
    ) {
        self.text = text
        self.icon = icon
        self.isDisable = isDisable
        self.category = category
        self.state = state
        self.type = type
        self.shape = shape
        self.size = size
        self.action = action
    }
    
    public var body: some View {
        Button(action: self.action) {
            self.label
        }
        .disabled(isDisable)
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
            } else {
                Image(systemName: "questionmark")
                    .resizable()
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
    
    public func state(_ state: Self.Style) -> Self {
        return .init(
            text: self.text,
            icon: self.icon,
            isDisable: self.isDisable,
            category: self.category,
            state: state,
            type: self.type,
            shape: self.shape,
            size: self.size,
            action: self.action
        )
    }
    
    public func disable(_ isDisable: Bool = true) -> Self {
        return .init(
            text: self.text,
            icon: self.icon,
            isDisable: isDisable,
            category: self.category,
            state: self.state,
            type: self.type,
            shape: self.shape,
            size: self.size,
            action: self.action
        )
    }
    
    public func type(_ type: Self.ButtonType) -> Self {
        return .init(
            text: self.text,
            icon: self.icon,
            isDisable: self.isDisable,
            category: self.category,
            state: self.state,
            type: type,
            shape: self.shape,
            size: self.size,
            action: self.action
        )
    }
    
    public func shape(_ shape: Self.Shape) -> Self {
        return .init(
            text: self.text,
            icon: self.icon,
            isDisable: self.isDisable,
            category: self.category,
            state: self.state,
            type: self.type,
            shape: shape,
            size: self.size,
            action: self.action
        )
    }
    
    public func size(_ size: Self.Size) -> Self {
        return .init(
            text: self.text,
            icon: self.icon,
            isDisable: self.isDisable,
            category: self.category,
            state: self.state,
            type: self.type,
            shape: self.shape,
            size: size,
            action: self.action
        )
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
        if !isDisable {
            switch self.state {
            case .filled: return .pokit(.icon(.inverseWh))
            case .stroke: return .pokit(.icon(.primary))
            case .default: return .pokit(.icon(.secondary))
            }
        } else {
            return .pokit(.icon(.disable))
        }
    }
    
    private var textColor: Color {
        if !isDisable {
            switch self.state {
            case .filled: return .pokit(.text(.inverseWh))
            case .stroke: return .pokit(.text(.primary))
            case .default: return .pokit(.text(.tertiary))
            }
        } else {
            return .pokit(.text(.disable))
        }
    }
    
    private var backgroundColor: Color {
        if !isDisable {
            switch self.state {
            case .filled:
                switch self.type {
                case .primary: return .pokit(.bg(.brand))
                case .secondary: return .pokit(.bg(.tertiary))
                }
            case .stroke, .default: return .pokit(.bg(.base))
            }
        } else {
            return .pokit(.bg(.disable))
        }
    }
    
    private var strokeColor: Color {
        if !isDisable {
            switch self.state {
            case .default: return .pokit(.border(.secondary))
            case .filled, .stroke:
                switch self.type {
                case .primary: return .pokit(.border(.brand))
                case .secondary: return .pokit(.border(.secondary))
                }
            }
        } else {
            return .pokit(.border(.disable))
        }
    }
    
    private var radius: CGFloat {
        switch self.shape {
        case .rectangle: return 8
        case .round: return 9999
        }
    }
}

public extension PokitButton {
    enum Category {
        case iconL
        case iconR
        case textOnly
        case iconOnly
    }
    
    enum Style {
        case `default`
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
    LazyVGrid(columns: [.init(.adaptive(minimum: 111, maximum: 111))]) {
        PokitButton(
            text: "버튼",
            icon: .icon(.search)
        ) {
            
        }
        .state(.filled)
        .disable(false)
        .size(.large)
        
        PokitButton(
            text: "버튼",
            icon: .icon(.search),
            state: .filled,
            type: .primary
        ) {
            
        }
        
        PokitButton(
            text: "버튼",
            icon: .icon(.search),
            category: .iconOnly,
            state: .filled,
            type: .primary
        ) {
            
        }
        
        PokitButton(
            text: "버튼",
            icon: .icon(.search),
            category: .textOnly,
            state: .filled,
            type: .primary
        ) {
            
        }
    }
}
