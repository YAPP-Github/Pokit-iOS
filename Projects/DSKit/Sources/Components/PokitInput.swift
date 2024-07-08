//
//  PokitInput.swift
//  DSKit
//
//  Created by 김도형 on 6/22/24.
//

import SwiftUI

public struct PokitInput<Value: Hashable>: View {
    @Binding private var text: String
    
    @State private var state: PokitInputStyle.State
    
    private var focusState: FocusState<Value>.Binding
    
    private let shape: PokitInputStyle.Shape
    private let equals: Value
    private let placeholder: String
    private let onSubmit: (() -> Void)?
    
    public init(
        text: Binding<String>,
        state: PokitInputStyle.State = .default,
        placeholder: String = "내용을 입력해주세요.",
        shape: PokitInputStyle.Shape,
        focusState: FocusState<Value>.Binding,
        equals: Value,
        onSubmit: (() -> Void)? = nil
    ) {
        self._text = text
        self.state = state
        self.shape = shape
        self.focusState = focusState
        self.equals = equals
        self.placeholder = placeholder
        self.onSubmit = onSubmit
    }
    
    public var body: some View {
        textField
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
        .padding(.vertical, shape == .round ? 11 : 16)
        .padding(.horizontal, shape == .round ? 20 : 12)
        .background(
            state: self.state,
            shape: shape
        )
        .onChange(of: focusState.wrappedValue) { onChangedFocuseState($0) }
    }
    
    private var placeholderLabel: some View {
        Text(placeholder)
            .foregroundStyle(self.state.infoColor)
    }
    
    private func onChangedFocuseState(_ newValue: Value) {
        state = newValue == equals ? .active : state == .error ? .error : .default
    }
}
