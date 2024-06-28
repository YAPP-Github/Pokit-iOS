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
    private let label: String
    private let info: String
    private let showInfo: Bool
    private let maxLetter: Int
    private let onSubmit: (() -> Void)?
    
    public init(
        text: Binding<String>,
        label: String,
        state: PokitInputStyle.State = .default,
        info: String = "내용을 입력해주세요.",
        showInfo: Bool = true,
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
        self.info = info
        self.showInfo = showInfo
        self.maxLetter = maxLetter
        self.onSubmit = onSubmit
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            PokitLabel(text: label, size: .large)
                .padding(.bottom, 8)
            
            textField
            
            infoLabel
        }
        .onChange(of: text) { newValue in
            isMaxLetters = text.count > maxLetter ? true : false
        }
        .onChange(of: isMaxLetters) { newValue in
            if isMaxLetters {
                state = .error
            }
        }
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
        .onChange(of: focusState.wrappedValue) { newValue in
            if newValue == equals {
                self.state = .active
            } else {
                self.state = state == .error ? .error : .default
            }
        }
    }
    
    private var placeholder: some View {
        Text(info)
            .foregroundStyle(self.state.infoColor)
    }
    
    private var infoLabel: some View {
        HStack(spacing: 4) {
            if state == .error {
                Image(.icon(.info))
                    .resizable()
                    .foregroundStyle(.pokit(.icon(.error)))
                    .frame(width: 20, height: 20)
                    .blurTransition(.smooth)
            }
            
            if isMaxLetters {
                Text("최대 \(maxLetter)자까지 입력가능합니다.")
                    .pokitFont(.detail1)
                    .foregroundStyle(.pokit(.text(.error)))
                    .blurTransition(.smooth)
            } else {
                if showInfo {
                    Text(info)
                        .pokitFont(.detail1)
                        .foregroundStyle(
                            state == .error ? .pokit(.text(.error)) : .pokit(.text(.tertiary))
                        )
                        .animation(.smooth, value: state == .error)
                }
            }
            
            Spacer()
            
            Text("\(text.count)/\(maxLetter)")
                .pokitFont(.detail1)
                .foregroundStyle(
                    state == .error ? .pokit(.text(.error)) : .pokit(.text(.tertiary))
                )
        }
        .padding(.top, 4)
    }
}
