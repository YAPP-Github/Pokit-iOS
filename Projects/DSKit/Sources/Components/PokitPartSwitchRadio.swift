//
//  PokitPartSwitchRadio.swift
//  DSKit
//
//  Created by 김도형 on 6/30/24.
//

import SwiftUI

public struct PokitPartSwitchRadio<Selection: Equatable>: View {
    @Binding private var selection: Selection
    
    private let labelText: String
    private let current: Selection
    private let state: PokitPartSwitchRadio.RadioState
    private let style: PokitPartSwitchRadio.Style
    private let action: (() -> Void)?
    
    public init(
        labelText: String,
        selection: Binding<Selection>,
        to current: Selection,
        style: PokitPartSwitchRadio.Style,
        isDisable: Bool = false,
        action: (() -> Void)? = nil
    ) {
        self.labelText = labelText
        self._selection = selection
        self.current = current
        self.style = style
        if isDisable {
            self.state = .disable
        } else {
            let isSelected = selection.wrappedValue == current
            self.state = isSelected ? .active(style) : .default(style)
        }
        self.action = action
    }
    
    public var body: some View {
        radioButton
    }
    
    private var radioButton: some View {
        Button {
            self.selection = current
        } label: {
            buttonLabel
        }
        .disabled(state == .disable)
    }
    
    private var buttonLabel: some View {
        HStack {
            Spacer()
            
            Text(labelText)
                .foregroundStyle(state.textColor)
                .pokitFont(.b2(.m))
            
            Spacer()
        }
        .padding(.vertical, 16)
    }
    
    @ViewBuilder
    private func background(_ state: PokitPartSwitchRadio.RadioState) -> some View {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(state.backgroundColor)
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(
                        state.backgroundStrokeColor,
                        lineWidth: 1
                    )
            }
    }
    
    public func background() -> some View {
        self
            .background {
                if state == .active(self.style) {
                    self.background(.active(self.style))
                } else {
                    self.background(.default(self.style))
                }
            }
            .animation(.smooth, value: self.selection)
    }
    
    public func matchedGeometryEffectBackground(
        id: Namespace.ID
    ) -> some View {
        self
            .background {
                if state == .active(self.style) {
                    self.background(.active(self.style))
                        .matchedGeometryEffect(id: "ACTIVE", in: id)
                } else {
                    self.background(.default(self.style))
                }
            }
            .animation(.snappy, value: self.selection)
    }
}

extension PokitPartSwitchRadio {
    enum RadioState: Equatable {
        case `default`(PokitPartSwitchRadio.Style)
        case active(PokitPartSwitchRadio.Style)
        case disable
        
        var backgroundColor: Color {
            switch self {
            case .default(let style):
                switch style {
                case .filled: return .pokit(.bg(.primary))
                case .stroke: return .pokit(.bg(.base))
                }
            case .active(let style):
                switch style {
                case .filled: return .pokit(.bg(.brand))
                case .stroke: return .pokit(.bg(.base))
                }
            case .disable:
                return .pokit(.bg(.disable))
            }
        }
        
        var backgroundStrokeColor: Color {
            switch self {
            case .default(let style):
                switch style {
                case .filled: return .clear
                case .stroke: return .pokit(.border(.secondary))
                }
            case .active:
                return .pokit(.border(.brand))
            case .disable:
                return .clear
            }
        }
        
        var textColor: Color {
            switch self {
            case .default: return .pokit(.text(.tertiary))
            case .active(let style):
                switch style {
                case .filled: return .pokit(.text(.inverseWh))
                case .stroke: return .pokit(.text(.brand))
                }
            case .disable: return .pokit(.text(.disable))
            }
        }
    }
    
    public enum Style: Hashable {
        case filled
        case stroke
    }
}

enum RadioButton: String {
    case button1 = "버튼1"
    case button2 = "버튼2"
}

