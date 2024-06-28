//
//  PokitSwitchRadio.swift
//  DSKit
//
//  Created by 김도형 on 6/28/24.
//

import SwiftUI

public struct PokitSwitchRadio: View {
    @State private var selection: PokitSwitchRadio.Selection
    
    private let leftLabelText: String
    private let rightLableText: String
    private let isDisable: Bool
    private let style: PokitSwitchRadio.Style
    private let delegateAction: ((PokitSwitchRadio.Delegate) -> Void)?
    
    public init(
        leftLabelText: String,
        rightLabelText: String,
        selection: PokitSwitchRadio.Selection,
        isDisable: Bool = false,
        style: PokitSwitchRadio.Style,
        delegateAction: ((PokitSwitchRadio.Delegate) -> Void)? = nil
    ) {
        self.leftLabelText = leftLabelText
        self.rightLableText = rightLabelText
        self.selection = selection
        self.isDisable = isDisable
        self.style = style
        self.delegateAction = delegateAction
    }
    
    public var body: some View {
        HStack(spacing: 8) {
            radioButton(.left)
            
            radioButton(.right)
        }
    }
    
    @ViewBuilder
    private func radioButton(_ selection: Selection) -> some View {
        let isSelected = self.selection == selection
        let state: PokitSwitchRadio.RadioState = isDisable ? .disable : (isSelected ? .active(self.style) : .default(self.style))
        
        Button {
            switch selection {
            case .left:
                delegateAction?(.leftButtonTapped)
            case .right:
                delegateAction?(.rightButtonTapped)
            }
            
            self.selection = selection
        } label: {
            HStack {
                Spacer()
                
                Group {
                    switch selection {
                    case .left:
                        Text(leftLabelText)
                    case .right:
                        Text(rightLableText)
                    }
                }
                .foregroundStyle(state.textColor)
                .pokitFont(.b2(.m))
                
                Spacer()
            }
            .padding(.vertical, 16)
            .background {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(state.backgroundColor)
                    .overlay {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(state.backgroundStrokeColor, lineWidth: 1)
                    }
            }
        }
    }
}

public extension PokitSwitchRadio {
    enum Selection {
        case left
        case right
    }
    
    enum RadioState {
        case `default`(PokitSwitchRadio.Style)
        case active(PokitSwitchRadio.Style)
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
    
    enum Style: Hashable {
        case filled
        case stroke
    }
    
    enum Delegate {
        case leftButtonTapped
        case rightButtonTapped
    }
}
