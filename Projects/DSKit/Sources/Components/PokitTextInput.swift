//
//  PokitTextInput.swift
//  DSKit
//
//  Created by 김도형 on 6/23/24.
//

import SwiftUI

public struct PokitTextInput: View {
    @Binding private var text: String
    @Binding private var isError: Bool
    
    private let label: String
    private let info: String
    private let showInfo: Bool
    private let isDisable: Bool
    private let isReadOnly: Bool
    private let onSubmit: (() -> Void)?
    
    public init(
        text: Binding<String>,
        isError: Binding<Bool> = .constant(false),
        label: String,
        info: String = "내용을 입력해주세요.",
        showInfo: Bool = false,
        isDisable: Bool = false,
        isReadOnly: Bool = false,
        onSubmit: (() -> Void)? = nil
    ) {
        self._text = text
        self._isError = isError
        self.label = label
        self.info = info
        self.showInfo = showInfo
        self.isDisable = isDisable
        self.isReadOnly = isReadOnly
        self.onSubmit = onSubmit
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            PokitLabel(text: label, size: .large)
                .padding(.bottom, 8)
            
            PokitInput(
                text: $text,
                isError: $isError,
                info: info,
                isDisable: isDisable,
                isReadOnly: isReadOnly,
                onSubmit: onSubmit
            )
            .padding(.bottom, 4)
            
            if showInfo {
                infoLabel
            }
        }
    }
    
    private var infoLabel: some View {
        HStack(spacing: 4) {
            if isError {
                Image(.icon(.info))
                    .resizable()
                    .foregroundStyle(.pokit(.icon(.error)))
                    .frame(width: 20, height: 20)
                    .blurTransition(.smooth)
            }
            
            Text(info)
                .pokitFont(.detail1)
                .foregroundStyle(
                    isError ? .pokit(.text(.error)) : .pokit(.text(.tertiary))
                )
                .animation(.smooth, value: isError)
        }
    }
}

#Preview {
    VStack {
        PokitTextInput(
            text: .constant(""),
            label: "Label"
        )
        
        PokitTextInput(
            text: .constant(""),
            label: "Label",
            showInfo: true
        )
        
        PokitTextInput(
            text: .constant(""),
            isError: .constant(true),
            label: "Label",
            showInfo: true
        )
    }
    .padding()
}
