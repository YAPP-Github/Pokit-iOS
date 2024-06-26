//
//  PokitButtonBackgroundModifier.swift
//  DSKit
//
//  Created by 김도형 on 6/26/24.
//

import SwiftUI

struct PokitButtonBackgroundModifier: ViewModifier {
    private let state: PokitButtonStyle.State
    private let shape: PokitButtonStyle.Shape
    
    init(
        state: PokitButtonStyle.State,
        shape: PokitButtonStyle.Shape
    ) {
        self.state = state
        self.shape = shape
    }
    
    func body(content: Content) -> some View {
        content
            .background(background)
    }
    
    private var background: some View {
        RoundedRectangle(cornerRadius: shape.radius, style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/)
            .fill(state.backgroundColor)
            .overlay {
                RoundedRectangle(cornerRadius: shape.radius, style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/)
                    .stroke(state.backgroundStrokeColor, lineWidth: 1)
            }
    }
}

extension View {
    func pokitButtonBackground(
        state: PokitButtonStyle.State,
        shape: PokitButtonStyle.Shape
    ) -> some View {
        modifier(PokitButtonBackgroundModifier(
            state: state,
            shape: shape
        ))
    }
}
