//
//  PokitIconRInput.swift
//  DSKit
//
//  Created by 김도형 on 6/28/24.
//

import SwiftUI

public struct PokitIconRInput: View {
    @Binding private var text: String
    
    private let icon: PokitImage
    
    @State private var state: PokitInputStyle.State
    
    private let info: String
    private let onSubmit: (() -> Void)?
    
    public init(
        text: Binding<String>,
        icon: PokitImage,
        state: PokitInputStyle.State = .default,
        info: String = "내용을 입력해주세요.",
        onSubmit: (() -> Void)? = nil
    ) {
        self._text = text
        self.icon = icon
        self.state = state
        self.info = info
        self.onSubmit = onSubmit
    }
    
    public var body: some View {
        HStack(spacing: 8) {
            textField
            
            iconButton(icon: icon)
        }
        .onChange(of: text) { newValue in
            state = text != "" ? .input : .default
        }
    }
    
    private var textField: some View {
        TextField(text: $text) {
            label
        }
        .autocorrectionDisabled()
        .textInputAutocapitalization(.never)
        .pokitFont(.b3(.m))
        .foregroundStyle(.pokit(.text(.secondary)))
        .disabled(state == .disable || state == .readOnly)
        .onSubmit {
            onSubmit?()
        }
    }
    
    private var label: some View {
        Text(info)
            .foregroundStyle(self.state.infoColor)
    }
    
    @ViewBuilder
    private func iconButton(icon: PokitImage) -> some View {
        Button {
            onSubmit?()
        } label: {
            Image(icon)
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundStyle(state.iconColor)
                .animation(.smooth, value: self.state)
        }
    }
    
    public func background(
        shape: PokitInputStyle.Shape,
        focusState: FocusState<Bool>.Binding
    ) -> some View {
        return self
            .padding(.vertical, 13)
            .padding(.leading, shape == .round ? 20 : 12)
            .padding(.trailing, 13)
            .background(
                state: self.state,
                shape: shape,
                focusState: focusState
            )
    }
    
    public func background<Value: Hashable>(
        shape: PokitInputStyle.Shape,
        focusState: FocusState<Value>.Binding,
        equals: Value
    ) -> some View {
        return self
            .padding(.vertical, 13)
            .padding(.leading, shape == .round ? 20 : 12)
            .padding(.trailing, 13)
            .background(
                state: self.state,
                shape: shape,
                focusState: focusState,
                equals: equals
            )
    }
}
