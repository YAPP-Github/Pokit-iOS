//
//  PokitPartTextArea.swift
//  DSKit
//
//  Created by 김도형 on 6/23/24.
//

import SwiftUI

public struct PokitPartTextArea: View {
    @Binding private var text: String
    @Binding private var isError: Bool
    
    @FocusState private var isFocused: Bool
    
    private let info: String
    private let isDisable: Bool
    private let isReadOnly: Bool
    private let onSubmit: (() -> Void)?
    
    public init(
        text: Binding<String>,
        isError: Binding<Bool> = .constant(false),
        info: String = "내용을 입력해주세요.",
        isDisable: Bool = false,
        isReadOnly: Bool = false,
        onSubmit: (() -> Void)? = nil
    ) {
        self._text = text
        self._isError = isError
        self.info = info
        self.isDisable = isDisable
        self.isReadOnly = isReadOnly
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
            .scrollContentBackground(.hidden)
            .focused($isFocused)
            .onSubmit {
                onSubmit?()
            }
            .background(alignment: .topLeading) {
                if text.isEmpty {
                    Text(info)
                        .pokitFont(.b3(.r))
                        .foregroundStyle(.pokit(.text(.tertiary)))
                        .padding(.leading, 4)
                }
            }
            .pokitFont(.b3(.r))
            .padding(16)
            .background {
                background
            }
    }
    
    private var background: some View {
        RoundedRectangle(cornerRadius: 8, style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/)
            .fill(backgroundColor)
            .overlay {
                border
            }
    }
    
    private var border: some View {
        if isError {
            RoundedRectangle(cornerRadius: 8, style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/)
                .stroke(.pokit(.border(.error)), lineWidth: 1)
                .animation(.smooth, value: isError)
        } else if isFocused {
            RoundedRectangle(cornerRadius: 8, style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/)
                .stroke(.pokit(.border(.brand)), lineWidth: 1)
                .animation(.smooth, value: isFocused)
        } else {
            RoundedRectangle(cornerRadius: 8, style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/)
                .stroke(.pokit(.border(.secondary)), lineWidth: 1)
                .animation(.smooth, value: isFocused)
        }
    }
    
    private var backgroundColor: Color {
        if isReadOnly {
            return .pokit(.bg(.secondary))
        } else if isDisable {
            return .pokit(.bg(.disable))
        } else {
            return .pokit(.bg(.base))
        }
    }
}

#Preview {
    VStack {
        PokitPartTextArea(
            text: .constant("")
        )
        
        PokitPartTextArea(
            text: .constant("내용을 입력해주세요.")
        )
        
        PokitPartTextArea(
            text: .constant("")
        )
        
        PokitPartTextArea(
            text: .constant(""),
            isDisable: true
        )
        
        PokitPartTextArea(
            text: .constant(""),
            isReadOnly: true
        )
        
        PokitPartTextArea(
            text: .constant(""),
            isError: .constant(true)
        )
    }
    .padding()
}
