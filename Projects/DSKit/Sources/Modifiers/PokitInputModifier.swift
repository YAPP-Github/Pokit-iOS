//
//  PokitInputModifier.swift
//  DSKit
//
//  Created by 김도형 on 6/28/24.
//

import SwiftUI

struct PokitInputModifier: ViewModifier {
    private let state: PokitInputStyle.State
    private let shape: PokitInputStyle.Shape
    
    init(
        state: PokitInputStyle.State,
        shape: PokitInputStyle.Shape
    ) {
        self.state = state
        self.shape = shape
    }
    
    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: shape.radius, style: .continuous)
                    .fill(self.state.backgroundColor)
                    .overlay {
                        RoundedRectangle(cornerRadius: shape.radius, style: .continuous)
                            .stroke(self.state.backgroundStrokeColor, lineWidth: 1)
                    }
            }
            .animation(.pokitDissolve, value: state)
    }
}

extension View {
    func background(
        state: PokitInputStyle.State,
        shape: PokitInputStyle.Shape
    ) -> some View {
        modifier(PokitInputModifier(
            state: state,
            shape: shape
        ))
    }
}
