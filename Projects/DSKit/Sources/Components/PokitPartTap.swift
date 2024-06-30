//
//  PokitPartTap.swift
//  DSKit
//
//  Created by 김도형 on 7/1/24.
//

import SwiftUI

public struct PokitPartTap<Selection: Equatable>: View {
    @Binding private var selection: Selection
    
    private let labelText: String
    private let current: Selection
    private let isSelected: Bool
    private let action: (() -> Void)?
    
    public init(
        _ labelText: String,
        selection: Binding<Selection>,
        to current: Selection,
        action: (() -> Void)? = nil
    ) {
        self.labelText = labelText
        self._selection = selection
        self.current = current
        self.isSelected = selection.wrappedValue == current
        self.action = action
    }
    
    public var body: some View {
        tapButton
    }
    
    private var tapButton: some View {
        Button {
            selection = current
            action?()
        } label: {
            buttonLabel
        }
    }
    
    private var buttonLabel: some View {
        HStack {
            Spacer()
            
            Text(labelText)
                .pokitFont(.l1(.b))
                .foregroundStyle(
                    isSelected ? .pokit(.text(.secondary)) : .pokit(.text(.tertiary))
                )
            
            Spacer()
        }
        .padding(.top, 4)
        .padding(.bottom, 16)
    }
    
    private var selectedBackground: some View {
        Rectangle()
            .fill(.pokit(.border(.brand)))
            .frame(height: 2)
    }
    
    public func matchedGeometryEffectBackground(
        id: Namespace.ID
    ) -> some View {
        self
            .background(alignment: .bottom) {
                if isSelected {
                    self.selectedBackground
                        .matchedGeometryEffect(id: "SELECT", in: id)
                }
            }
            .animation(.smooth, value: self.selection)
    }
}

enum TapButton: String {
    case tap1 = "탭1"
    case tap2 = "탭2"
    case tap3 = "탭3"
}

