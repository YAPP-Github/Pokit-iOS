//
//  PokitTextInput.swift
//  DSKit
//
//  Created by 김도형 on 6/23/24.
//

import SwiftUI

public struct PokitTextInput<Value: Hashable>: View {
    @Binding private var text: String
    
    @Binding private var state: PokitInputStyle.State
    @State private var isMaxLetters: Bool = false
    
    private var focusState: FocusState<Value>.Binding
    
    private let type: PokitInputStyle.InputType
    private let shape: PokitInputStyle.Shape
    private let equals: Value
    private let label: String?
    private let placeholder: String
    private let info: String?
    private let maxLetter: Int?
    private let onSubmit: (() -> Void)?
    
    public init(
        text: Binding<String>,
        label: String? = nil,
        type: PokitInputStyle.InputType = .text,
        shape: PokitInputStyle.Shape,
        state: Binding<PokitInputStyle.State>,
        placeholder: String = "내용을 입력해주세요.",
        info: String? = nil,
        maxLetter: Int? = nil,
        focusState: FocusState<Value>.Binding,
        equals: Value,
        onSubmit: (() -> Void)? = nil
    ) {
        self._text = text
        self.label = label
        self.type = type
        self.shape = shape
        self._state = state
        self.focusState = focusState
        self.equals = equals
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
            
            HStack(spacing: 8) {
                if case let .iconL(icon, action) = type {
                    iconButton(icon: icon, action: action)
                }
                
                textField
                
                if case let .iconR(icon, action) = type {
                    iconButton(icon: icon, action: action)
                }
            }
            .padding(.vertical, vPadding)
            .padding(.leading, lPadding)
            .padding(.trailing, tPadding)
            .background(
                state: self.state,
                shape: self.shape
            )
            
            infoLabel
        }
        .onChange(of: text) { onChangedText($0) }
        .onChange(of: isMaxLetters) { onChangedIsMaxLetters($0) }
        .onChange(of: state) { onChangedState($0) }
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
    
    private var infoLabel: some View {
        HStack(spacing: 4) {
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
            
            if let maxLetter {
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
        }
        .padding(.top, 4)
    }
    
    @ViewBuilder
    private func iconButton(
        icon: PokitImage,
        action: (() -> Void)?
    ) -> some View {
        Button {
            if let action {
                action()
            } else {
                onSubmit?()
            }
        } label: {
            Image(icon)
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundStyle(state.iconColor)
                .animation(.pokitDissolve, value: self.state)
        }
    }
    
    private var vPadding: CGFloat {
        switch type {
        case .text: return 16
        case .iconR, .iconL:
            switch shape {
            case .rectangle: return 13
            case .round: return 8
            }
        }
    }
    
    private var tPadding: CGFloat {
        switch type {
        case .text: return 12
        case .iconR:
            switch shape {
            case .rectangle: return 12
            case .round: return 20
            }
        case .iconL: return 13
        }
    }
    
    private var lPadding: CGFloat {
        switch type {
        case .text: return 12
        case .iconL:
            switch shape {
            case .rectangle: return 12
            case .round: return 20
            }
        case .iconR: return 13
        }
    }
    
    private func onChangedText(_ newValue: String) {
        guard let maxLetter else { return }
        
        if isMaxLetters {
            self.text = String(newValue.prefix(maxLetter + 1))
        }
        isMaxLetters = text.count > maxLetter ? true : false
    }
    
    private func onChangedIsMaxLetters(_ newValue: Bool) {
        if isMaxLetters, let maxLetter {
            state = .error(message: "최대 \(maxLetter)자까지 입력가능합니다.")
        } else {
            state = .active
        }
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
    
    private func onChangedState(_ newValue: PokitInputStyle.State) {
        switch newValue {
        case .error:
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        default: return
        }
    }
}
