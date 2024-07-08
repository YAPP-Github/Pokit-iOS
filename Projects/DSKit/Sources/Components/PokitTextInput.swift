//
//  PokitTextInput.swift
//  DSKit
//
//  Created by 김도형 on 6/23/24.
//

import SwiftUI

public struct PokitTextInput<Value: Hashable>: View {
    @Binding private var text: String
    
    @State private var state: PokitInputStyle.State
    @State private var isMaxLetters: Bool = false
    
    private var focusState: FocusState<Value>.Binding
    
    private let equals: Value
    private let label: String?
    private let errorMessage: String?
    private let placeholder: String
    private let info: String?
    private let maxLetter: Int
    private let onSubmit: (() -> Void)?
    
    public init(
        text: Binding<String>,
        label: String? = nil,
        state: PokitInputStyle.State = .default,
        errorMessage: String? = nil,
        placeholder: String = "내용을 입력해주세요.",
        info: String? = nil,
        maxLetter: Int = 10,
        focusState: FocusState<Value>.Binding,
        equals: Value,
        onSubmit: (() -> Void)? = nil
    ) {
        self._text = text
        self.label = label
        self.state = state
        self.focusState = focusState
        self.equals = equals
        self.errorMessage = errorMessage
        self.placeholder = placeholder
        self.info = info
        self.maxLetter = maxLetter
        self.onSubmit = onSubmit
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let label {
                PokitLabel(text: label, size: .large)
                    .padding(.bottom, 8)
            }
            
            textField
            
            infoLabel
        }
        .onChange(of: text) { onChangedText($0) }
        .onChange(of: isMaxLetters) { onChangedIsMaxLetters($0) }
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
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
        .background(
            state: self.state,
            shape: .rectangle
        )
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
    
    private var infoLabel: some View {
        HStack(spacing: 4) {
            if state == .error {
                Image(.icon(.info))
                    .resizable()
                    .foregroundStyle(.pokit(.icon(.error)))
                    .frame(width: 20, height: 20)
                    .pokitBlurReplaceTransition(.smooth)
            }
            
            Group {
                if isMaxLetters {
                    Text("최대 \(maxLetter)자까지 입력가능합니다.")
                        .foregroundStyle(.pokit(.text(.error)))
                } else if state == .error, let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.pokit(.text(.error)))
                } else if let info {
                    Text(info)
                        .foregroundStyle(.pokit(.text(.tertiary)))
                }
            }
            .pokitFont(.detail1)
            .pokitBlurReplaceTransition(.smooth)
            
            Spacer()
            
            Text("\(text.count > maxLetter ? maxLetter : text.count)/\(maxLetter)")
                .pokitFont(.detail1)
                .foregroundStyle(
                    state == .error ? .pokit(.text(.error)) : .pokit(.text(.tertiary))
                )
                .contentTransition(.numericText())
                .animation(.smooth, value: text)
        }
        .padding(.top, 4)
    }
    
    private func onChangedText(_ newValue: String) {
        if isMaxLetters {
            self.text = String(newValue.prefix(maxLetter + 1))
        }
        isMaxLetters = text.count > maxLetter ? true : false
    }
    
    private func onChangedIsMaxLetters(_ newValue: Bool) {
        if isMaxLetters {
            state = .error
        } else {
            state = .active
        }
    }
    
    private func onChangedFocuseState(_ newValue: Value) {
        state = newValue == equals ? .active : state == .error ? .error : .default
    }
}
