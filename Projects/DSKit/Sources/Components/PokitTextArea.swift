//
//  PokitTextArea.swift
//  DSKit
//
//  Created by 김도형 on 6/23/24.
//

import SwiftUI

public struct PokitTextArea: View {
    @Binding private var text: String
    @Binding private var isError: Bool
    
    @State private var isMaxLetters: Bool = false
    
    private let label: String
    private let info: String
    private let maxLetter: Int
    private let showInfo: Bool
    private let isDisable: Bool
    private let isReadOnly: Bool
    private let onSubmit: (() -> Void)?
    
    public init(
        text: Binding<String>,
        isError: Binding<Bool> = .constant(false),
        label: String,
        info: String = "내용을 입력해주세요.",
        maxLetter: Int = 100,
        showInfo: Bool = false,
        isDisable: Bool = false,
        isReadOnly: Bool = false,
        onSubmit: (() -> Void)? = nil
    ) {
        self._text = text
        self._isError = isError
        self.label = label
        self.info = info
        self.maxLetter = maxLetter
        self.showInfo = showInfo
        self.isDisable = isDisable
        self.isReadOnly = isReadOnly
        self.onSubmit = onSubmit
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            PokitLabel(text: label, size: .large)
                .padding(.bottom, 8)
            
            PokitPartTextArea(
                text: $text,
                isError: $isError,
                info: info,
                isDisable: isDisable,
                isReadOnly: isReadOnly,
                onSubmit: onSubmit
            )
            .padding(.bottom, 4)
            .onChange(of: text) { newValue in
                isMaxLetters = text.count > maxLetter ? true : false
                isError = text.count > maxLetter ? true : false
            }
            
            infoLabel
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
                    isError ? .pokit(.text(.error)) : .pokit(.text(.tertiary))
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
