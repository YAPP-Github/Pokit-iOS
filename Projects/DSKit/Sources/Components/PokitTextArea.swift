//
//  PokitTextArea.swift
//  DSKit
//
//  Created by 김도형 on 6/23/24.
//

import SwiftUI

public struct PokitTextArea<Value: Hashable>: View {
    @Binding private var text: String
    
    @State private var isMaxLetters: Bool = false
    @State private var state: PokitInputStyle.State
    
    private var focusState: FocusState<Value>.Binding
    
    private let errorMessage: String?
    private let equals: Value
    private let label: String
    private let placeholder: String
    private let info: String?
    private let maxLetter: Int
    private let onSubmit: (() -> Void)?
    
    public init(
        text: Binding<String>,
        label: String,
        state: PokitInputStyle.State = .default,
        errorMessage: String? = nil,
        placeholder: String = "내용을 입력해주세요.",
        info: String? = nil,
        maxLetter: Int = 100,
        focusState: FocusState<Value>.Binding,
        equals: Value,
        onSubmit: (() -> Void)? = nil
    ) {
        self._text = text
        self.label = label
        self.state = state
        self.errorMessage = errorMessage
        self.focusState = focusState
        self.equals = equals
        self.placeholder = placeholder
        self.info = info
        self.maxLetter = maxLetter
        self.onSubmit = onSubmit
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            PokitLabel(text: label, size: .large)
                .padding(.bottom, 8)
            
            PokitPartTextArea(
                text: $text,
                state: state,
                placeholder: placeholder,
                focusState: focusState,
                equals: equals,
                onSubmit: onSubmit
            )
            .onChange(of: focusState.wrappedValue) { newValue in
                if newValue == equals {
                    self.state = .active
                } else {
                    self.state = state == .error ? .error : .default
                }
            }
            
            infoLabel
        }
        .onChange(of: text) { newValue in
            self.onChangeOfText(newValue)
        }
        .onChange(of: isMaxLetters) { newValue in
            self.onChangeOfIsMaxLetters(newValue)
        }
    }
    
    private var infoLabel: some View {
        HStack {
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
    
    private func onChangeOfText(_ newValue: String) {
        if isMaxLetters {
            self.text = String(newValue.prefix(maxLetter + 1))
        }
        isMaxLetters = text.count > maxLetter ? true : false
    }
    
    private func onChangeOfIsMaxLetters(_ newValue: Bool) {
        if newValue {
            state = .error
        } else {
            state = .active
        }
    }
}

