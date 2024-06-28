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
    
    private let equals: Value
    
    private let label: String
    private let info: String
    private let maxLetter: Int
    private let showInfo: Bool
    private let onSubmit: (() -> Void)?
    
    public init(
        text: Binding<String>,
        label: String,
        state: PokitInputStyle.State = .default,
        info: String = "내용을 입력해주세요.",
        maxLetter: Int = 100,
        showInfo: Bool = false,
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
        self.maxLetter = maxLetter
        self.showInfo = showInfo
        self.onSubmit = onSubmit
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            PokitLabel(text: label, size: .large)
                .padding(.bottom, 8)
            
            PokitPartTextArea(
                text: $text,
                state: state,
                info: info,
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
            isMaxLetters = text.count > maxLetter ? true : false
        }
        .onChange(of: isMaxLetters) { newValue in
            if isMaxLetters {
                state = .error
            } else {
                state = .active
            }
        }
    }
    
    private var infoLabel: some View {
        HStack {
            if isMaxLetters {
                Text("최대 \(maxLetter)자까지 입력가능합니다.")
                    .pokitFont(.detail1)
                    .foregroundStyle(.pokit(.text(.error)))
                    .blurTransition(.smooth)
            }
            
            Spacer()
            
            Text("\(text.count)/\(maxLetter)")
                .pokitFont(.detail1)
                .foregroundStyle(
                    state == .error ? .pokit(.text(.error)) : .pokit(.text(.tertiary))
                )
        }
    }
}

#Preview {
    VStack {
        PokitTextArea(
            text: .constant(""),
            label: "Label",
            showInfo: true
        )
        
        PokitTextArea(
            text: .constant(""),
            isError: .constant(true),
            label: "Label",
            showInfo: true
        )
    }
    .padding()
}
