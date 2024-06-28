//
//  PokitInput.swift
//  DSKit
//
//  Created by 김도형 on 6/22/24.
//

import SwiftUI

public struct PokitInput: View {
    @Binding private var text: String
    
    @State private var state: PokitInputStyle.State
    
    private let info: String
    private let onSubmit: (() -> Void)?
    
    public init(
        text: Binding<String>,
        state: PokitInputStyle.State = .default,
        info: String = "내용을 입력해주세요.",
        onSubmit: (() -> Void)? = nil
    ) {
        self._text = text
        self.state = state
        self.info = info
        self.onSubmit = onSubmit
    }
    
    public var body: some View {
        textField
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
    
    public func background(
        shape: PokitInputStyle.Shape,
        focusState: FocusState<Bool>.Binding
    ) -> some View {
        self
            .padding(.vertical, 16)
            .padding(.horizontal, shape == .round ? 20 : 12)
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
        self
            .padding(.vertical, 16)
            .padding(.horizontal, shape == .round ? 20 : 12)
            .background(
                state: self.state,
                shape: shape,
                focusState: focusState,
                equals: equals
            )
    }
}
