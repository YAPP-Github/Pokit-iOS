//
//  PokitIconLInput.swift
//  DSKit
//
//  Created by 김도형 on 6/28/24.
//

import SwiftUI

public struct PokitIconLInput<Value: Hashable>: View {
    @Binding private var text: String
    
    private let icon: PokitImage
    
    @State private var state: PokitInputStyle.State
    
    private var focusState: FocusState<Value>.Binding
    
    private let shape: PokitInputStyle.Shape
    private let equals: Value
    private let placeholder: String
    private let onSubmit: (() -> Void)?
    
    public init(
        text: Binding<String>,
        icon: PokitImage,
        state: PokitInputStyle.State = .default,
        placeholder: String = "내용을 입력해주세요.",
        shape: PokitInputStyle.Shape,
        focusState: FocusState<Value>.Binding,
        equals: Value,
        onSubmit: (() -> Void)? = nil
    ) {
        self._text = text
        self.icon = icon
        self.state = state
        self.shape = shape
        self.focusState = focusState
        self.equals = equals
        self.placeholder = placeholder
        self.onSubmit = onSubmit
    }
    
    public var body: some View {
        HStack(spacing: 8) {
            iconButton(icon: icon)
            
            textField
        }
        .onChange(of: text) { onChangedText($0) }
        .padding(.vertical, shape == .round ? 8 : 13)
        .padding(.trailing, shape == .round ? 20 : 12)
        .padding(.leading, 13)
        .background(
            state: self.state,
            shape: shape
        )
    }
    
    private var textField: some View {
        TextField(text: $text) {
            placeholderLabel
        }
        .autocorrectionDisabled()
        .textInputAutocapitalization(.never)
        .focused(focusState, equals: equals)
        .pokitFont(.b3(.m))
        .foregroundStyle(.pokit(.text(.secondary)))
        .disabled(state == .disable || state == .readOnly)
        .onSubmit {
            onSubmit?()
        }
        .onChange(of: focusState.wrappedValue) { onChangedFocuseState($0) }
    }
    
    private var placeholderLabel: some View {
        Text(placeholder)
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
    
    private func onChangedText(_ newValue: String) {
        state = newValue != "" ? .input : .default
    }
    
    private func onChangedFocuseState(_ newValue: Value) {
        state = newValue == equals ? .active : .default
    }
}
