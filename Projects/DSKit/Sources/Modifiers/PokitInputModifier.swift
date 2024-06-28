//
//  PokitInputModifier.swift
//  DSKit
//
//  Created by 김도형 on 6/28/24.
//

import SwiftUI

struct PokitInputModifier<Value: Hashable>: ViewModifier {
    private let state: PokitInputStyle.State
    private let shape: PokitInputStyle.Shape
    private var focusState: FocusState<Value>.Binding
    private let equals: Value
    
    init(
        state: PokitInputStyle.State,
        shape: PokitInputStyle.Shape,
        focusState: FocusState<Value>.Binding,
        equals: Value
    ) {
        self.state = state
        self.shape = shape
        self.focusState = focusState
        self.equals = equals
    }
    
    func body(content: Content) -> some View {
        let backgroundColor = focusState.wrappedValue == equals ? .pokit(.bg(.base)) : self.state.backgroundColor
        let backgroundStrokeColor = focusState.wrappedValue == equals ? .pokit(.border(.brand)) : self.state.backgroundStrokeColor
        
        content
            .focused(focusState, equals: equals)
            .background {
                RoundedRectangle(cornerRadius: shape.radius, style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/)
                    .fill(backgroundColor)
                    .overlay {
                        RoundedRectangle(cornerRadius: shape.radius, style: .continuous)
                            .stroke(backgroundStrokeColor, lineWidth: 1)
                    }
            }
            .animation(.smooth, value: focusState.wrappedValue)
    }
}

extension View {
    func background(
        state: PokitInputStyle.State,
        shape: PokitInputStyle.Shape,
        focusState: FocusState<Bool>.Binding
    ) -> some View {
        modifier(PokitInputModifier(
            state: state,
            shape: shape,
            focusState: focusState,
            equals: true
        ))
    }
    
    func background<Value: Hashable>(
        state: PokitInputStyle.State,
        shape: PokitInputStyle.Shape,
        focusState: FocusState<Value>.Binding,
        equals: Value
    ) -> some View {
        modifier(PokitInputModifier(
            state: state,
            shape: shape,
            focusState: focusState,
            equals: equals
        ))
    }
}
