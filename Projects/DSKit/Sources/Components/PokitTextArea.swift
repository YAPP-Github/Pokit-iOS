//
//  PokitTextArea.swift
//  DSKit
//
//  Created by 김도형 on 6/23/24.
//

import SwiftUI

public struct PokitTextArea<Value: Hashable>: View {
    @Binding private var text: String
    @Binding private var state: PokitInputStyle.State
    
    @State private var isMaxLetters: Bool = false
    
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
        state: Binding<PokitInputStyle.State>,
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
        self._state = state
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
            .onChange(of: focusState.wrappedValue) { onChangedFocuseState($0) }
            
            infoLabel
        }
        .onChange(of: text) { onChangedText($0) }
        .onChange(of: isMaxLetters) { self.onChangedIsMaxLetters($0) }
    }
    
    private var infoLabel: some View {
        HStack {
            Group {
                switch state {
                case .error(let message):
                    Image(.icon(.info))
                        .resizable()
                        .foregroundStyle(.pokit(.icon(.error)))
                        .frame(width: 20, height: 20)
                        .pokitBlurReplaceTransition(.pokitDissolve)
                    
                    Text(message)
                        .foregroundStyle(.pokit(.text(.error)))
                default:
                    if let info {
                        Text(info)
                            .foregroundStyle(.pokit(.text(.tertiary)))
                    }
                }
            }
            .pokitFont(.detail1)
            .pokitBlurReplaceTransition(.pokitDissolve)
            
            Spacer()
            
            Group {
                switch state {
                case .error:
                    Text("\(text.count > maxLetter ? maxLetter : text.count)/\(maxLetter)")
                        .foregroundStyle(.pokit(.text(.error)))
                default:
                    Text("\(text.count > maxLetter ? maxLetter : text.count)/\(maxLetter)")
                        .foregroundStyle(.pokit(.text(.tertiary)))
                }
            }
            .pokitFont(.detail1)
            .contentTransition(.numericText())
            .animation(.pokitDissolve, value: text)
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
        state = newValue ? .error(message: "최대 \(maxLetter)자까지 입력가능합니다.") : .active
    }
    
    private func onChangedFocuseState(_ newValue: Value) {
        if newValue == equals {
            state = .active
        } else {
            switch state {
            case .error(message: let message):
                state = .error(message: message)
            default:
                state = .default
            }
        }
    }
}

