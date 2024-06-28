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
    
    private let equals: Value
    private let info: String
    private let onSubmit: (() -> Void)?
    
    public init(
        text: Binding<String>,
        state: PokitInputStyle.State = .default,
        info: String = "내용을 입력해주세요.",
        focusState: FocusState<Value>.Binding,
        equals: Value,
        onSubmit: (() -> Void)? = nil
    ) {
        self._text = text
        self.state = state
        self.focusState = focusState
        self.equals = equals
        self.info = info
        self.onSubmit = onSubmit
    }
    
    public var body: some View {
        textField
    }
    
    private var textField: some View {
        TextField(text: $text) {
            placeholder
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
    }
    
    private var placeholder: some View {
        Text(info)
            .foregroundStyle(self.state.infoColor)
    }
    
    public func background(
        shape: PokitInputStyle.Shape,
        focusState: FocusState<Bool>.Binding
    ) -> some View {
        self
            .padding(.vertical, 16)
            .padding(.horizontal, shape == .round ? 20 : 12)
            .focused(focusState)
            .background(
                state: self.state,
                shape: shape
            )
    }
    
    public func background(
        shape: PokitInputStyle.Shape
    ) -> some View {
        self
            .padding(.vertical, 16)
            .padding(.horizontal, shape == .round ? 20 : 12)
            .focused(focusState, equals: equals)
            .background(
                state: self.state,
                shape: shape
            )
    }
}
