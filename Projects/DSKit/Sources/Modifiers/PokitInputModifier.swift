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
        let backgroundColor = state == .active ? .pokit(.bg(.base)) : self.state.backgroundColor
        let backgroundStrokeColor = state == .active ? .pokit(.border(.brand)) : self.state.backgroundStrokeColor
        
        content
            .background {
                RoundedRectangle(cornerRadius: shape.radius, style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/)
                    .fill(backgroundColor)
                    .overlay {
                        RoundedRectangle(cornerRadius: shape.radius, style: .continuous)
                            .stroke(backgroundStrokeColor, lineWidth: 1)
                    }
            }
            .animation(.smooth, value: state)
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
