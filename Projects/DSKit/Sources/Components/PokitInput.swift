//
//  PokitInput.swift
//  DSKit
//
//  Created by 김도형 on 6/22/24.
//

import SwiftUI

public struct PokitInput: View {
    @Binding private var text: String
    @Binding private var isError: Bool
    
    @FocusState private var isFocused: Bool
    
    private let icon: PokitImage?
    private let info: String
    private let category: Self.Category
    private let isDisable: Bool
    private let isReadOnly: Bool
    private let shape: Self.Shape
    private let onSubmit: (() -> Void)?
    
    public init(
        text: Binding<String>,
        isError: Binding<Bool> = .constant(false),
        icon: PokitImage? = nil,
        info: String = "내용을 입력해주세요.",
        category: Self.Category = .textOnly,
        isDisable: Bool = false,
        isReadOnly: Bool = false,
        shape: Shape = .rectangle,
        onSubmit: (() -> Void)? = nil
    ) {
        self._text = text
        self._isError = isError
        self.icon = icon
        self.info = info
        self.category = category
        self.isDisable = isDisable
        self.isReadOnly = isReadOnly
        self.shape = shape
        self.onSubmit = onSubmit
    }
    
    public var body: some View {
        VStack {
            switch self.category {
            case .textOnly:
                textField
                    .padding(.vertical, 16)
                    .padding(.horizontal, 12)
            case .iconL:
                iconLabel()
            case .iconR:
                iconRLabel()
            }
        }
        .background {
            background
        }
    }
    
    private var textField: some View {
        TextField(text: $text) {
            label
        }
        .foregroundStyle(.pokit(.text(.secondary)))
        .disabled(isReadOnly || isDisable)
        .focused($isFocused)
        .pokitFont(.b3(.m))
        .autocorrectionDisabled()
        .textInputAutocapitalization(.never)
        .onSubmit {
            onSubmit?()
        }
    }
    
    private var label: some View {
        Text(info)
            .foregroundStyle(isDisable ? .pokit(.text(.disable)) : .pokit(.text(.tertiary)))
    }
    
    @ViewBuilder
    private func iconButton(icon: PokitImage) -> some View {
        let isDefault = isFocused && text.isEmpty
        
        Button {
            isFocused = false
            onSubmit?()
        } label: {
            Image(icon)
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundStyle(iconColor)
                .animation(.smooth, value: isDefault)
        }
    }
    
    @ViewBuilder
    private func iconLabel() -> some View {
        HStack(spacing: 8) {
            if let icon {
                iconButton(icon: icon)
            }
            
            textField
        }
        .padding(.vertical, 13)
        .padding(.horizontal, 12)
    }
    
    @ViewBuilder
    private func iconRLabel() -> some View {
        HStack(spacing: 8) {
            textField
            
            if let icon {
                iconButton(icon: icon)
            }
        }
        .padding(.vertical, 13)
        .padding(.horizontal, 12)
    }
    
    public func disable(_ isDisable: Bool = true) -> Self {
        return .init(
            text: self.$text,
            isError: self.$isError,
            icon: self.icon,
            info: self.info,
            category: self.category,
            isDisable: isDisable,
            isReadOnly: self.isReadOnly,
            shape: self.shape,
            onSubmit: self.onSubmit
        )
    }
    
    public func readOnly(_ isReadOnly: Bool = true) -> Self {
        return .init(
            text: self.$text,
            isError: self.$isError,
            icon: self.icon,
            info: self.info,
            category: self.category,
            isDisable: self.isDisable,
            isReadOnly: isReadOnly,
            shape: self.shape,
            onSubmit: self.onSubmit
        )
    }
    
    public func shape(_ shape: Self.Shape) -> Self {
        return .init(
            text: self.$text,
            isError: self.$isError,
            icon: self.icon,
            info: self.info,
            category: self.category,
            isDisable: self.isDisable,
            isReadOnly: self.isReadOnly,
            shape: shape,
            onSubmit: self.onSubmit
        )
    }
    
    private var background: some View {
        RoundedRectangle(cornerRadius: self.radius, style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/)
            .fill(backgroundColor)
            .overlay {
                border
            }
    }
    
    private var border: some View {
        if isError {
            RoundedRectangle(cornerRadius: self.radius, style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/)
                .stroke(.pokit(.border(.error)), lineWidth: 1)
                .animation(.smooth, value: isError)
        } else if isFocused {
            RoundedRectangle(cornerRadius: self.radius, style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/)
                .stroke(.pokit(.border(.brand)), lineWidth: 1)
                .animation(.smooth, value: isFocused)
        } else {
            RoundedRectangle(cornerRadius: self.radius, style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/)
                .stroke(.pokit(.border(.secondary)), lineWidth: 1)
                .animation(.smooth, value: isFocused)
        }
    }
    
    private var radius: CGFloat {
        switch self.shape {
        case .rectangle:
            return 4
        case .round:
            return 9999
        }
    }
    
    private var backgroundColor: Color {
        if isReadOnly {
            return .pokit(.bg(.secondary))
        } else if isDisable {
            return .pokit(.bg(.disable))
        } else {
            return .pokit(.bg(.base))
        }
    }
    
    private var iconColor: Color {
        if isError {
            return .pokit(.icon(.error))
        } else if isFocused && text.isEmpty {
            return .pokit(.icon(.primary))
        } else {
            return .pokit(.icon(.secondary))
        }
    }
}

public extension PokitInput {
    enum Category {
        case textOnly
        case iconL
        case iconR
    }
    
    enum Shape {
        case rectangle
        case round
    }
}

#Preview {
    VStack {
        PokitInput(
            text: .constant(""),
            icon: .icon(.search),
            category: .iconL
        )
        .shape(.rectangle)
        .readOnly()
        
        PokitInput(
            text: .constant(""),
            icon: .icon(.search),
            category: .iconR
        )
        
        PokitInput(
            text: .constant(""),
            icon: .icon(.search),
            category: .textOnly
        )
        
        PokitInput(
            text: .constant(""),
            icon: .icon(.search),
            category: .iconL,
            shape: .round
        )
        
        PokitInput(
            text: .constant(""),
            icon: .icon(.search),
            category: .iconR,
            shape: .round
        )
        
        PokitInput(
            text: .constant(""),
            icon: .icon(.search),
            category: .textOnly,
            shape: .round
        )
        
        PokitInput(
            text: .constant(""),
            icon: .icon(.search),
            category: .textOnly,
            isDisable: true,
            shape: .round
        )
        
        PokitInput(
            text: .constant(""),
            icon: .icon(.search),
            category: .textOnly,
            isReadOnly: true,
            shape: .round
        )
        
        PokitInput(
            text: .constant(""),
            isError: .constant(true),
            icon: .icon(.search),
            category: .iconL
        )
    }
    .padding()
}
