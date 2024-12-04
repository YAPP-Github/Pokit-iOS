//
//  PokitPartTextArea.swift
//  DSKit
//
//  Created by 김도형 on 6/23/24.
//

import SwiftUI

public struct PokitPartTextArea<Value: Hashable>: View {
    @Binding private var text: String
    
    @Binding private var state: PokitInputStyle.State
    
    private var focusState: FocusState<Value>.Binding
    private let baseState: PokitInputStyle.State
    private let equals: Value
    private let placeholder: String
    private let onSubmit: (() -> Void)?
    
    public init(
        text: Binding<String>,
        state: Binding<PokitInputStyle.State>,
        baseState: PokitInputStyle.State = .default,
        placeholder: String = "내용을 입력해주세요.",
        focusState: FocusState<Value>.Binding,
        equals: Value,
        onSubmit: (() -> Void)? = nil
    ) {
        self._text = text
        self._state = state
        self.baseState = baseState
        self.focusState = focusState
        self.equals = equals
        self.placeholder = placeholder
        self.onSubmit = onSubmit
        
        UITextView.appearance().textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    public var body: some View {
        textEditor
    }
    
    private var textEditor: some View {
        TextEditor(text: $text)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .foregroundStyle(.pokit(.text(.primary)))
            .scrollContentBackground(.hidden)
            .focused(focusState, equals: equals)
            .disabled(
                state == .disable ||
                state == .readOnly ||
                state == .memo(isReadOnly: true)
            )
            .onSubmit {
                onSubmit?()
            }
            .onChange(of: focusState.wrappedValue) { onChangedFocuseState($0) }
            .background(alignment: .topLeading) {
                if text.isEmpty {
                    placeholderLabel
                }
            }
            .pokitFont(.b3(.r))
            .padding(16)
            .background(state: self.state, shape: .rectangle)
    }
    
    private var placeholderLabel: some View {
        Text(placeholder)
            .pokitFont(.b3(.r))
            .foregroundStyle(.pokit(.text(.tertiary)))
            .padding(.leading, 4)
    }
    
    private func onChangedFocuseState(_ newValue: Value) {
        if newValue == equals {
            state = .active
        } else {
            switch state {
            case .error(message: let message):
                state = .error(message: message)
            default:
                state = baseState
            }
        }
    }
}
