//
//  View+Extension.swift
//  Util
//
//  Created by 김도형 on 12/1/24.
//

import SwiftUI

public extension View {
    @ViewBuilder
    func dismissKeyboard(
        focused: FocusState<Bool>.Binding
    ) -> some View {
        self
            .overlay {
                if focused.wrappedValue {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            focused.wrappedValue = false
                        }
                }
            }
    }
    
    @ViewBuilder
    func dismissKeyboard<Value: Hashable>(
        focused: FocusState<Value?>.Binding
    ) -> some View {
        self
            .overlay {
                if focused.wrappedValue != nil {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            focused.wrappedValue = nil
                        }
                }
            }
    }
    
    @ViewBuilder
    func overlay<V>(
        `if` condition: Bool,
        alignment: Alignment = .center,
        @ViewBuilder content: () -> V,
        @ViewBuilder `else`: () -> V? = { nil }
    ) -> some View where V : View {
        self
            .overlay(alignment: alignment) {
                if condition {
                    content()
                } else {
                    `else`()
                }
            }
    }
    
    @ViewBuilder
    func overlay<V, T>(
        ifLet optional: T?,
        alignment: Alignment = .center,
        @ViewBuilder content: (T) -> V,
        @ViewBuilder `else`: () -> V? = { nil }
    ) -> some View where V : View {
        self
            .overlay(alignment: alignment) {
                if let optional {
                    content(optional)
                } else {
                    `else`()
                }
            }
    }
    
    @ViewBuilder
    func background<V>(
        `if` condition: Bool,
        alignment: Alignment = .center,
        @ViewBuilder content: () -> V,
        @ViewBuilder `else`: () -> V? = { nil }
    ) -> some View where V : View {
        self
            .background(alignment: alignment) {
                if condition {
                    content()
                } else {
                    `else`()
                }
            }
    }
    
    @ViewBuilder
    func background<V, T>(
        ifLet optional: T?,
        alignment: Alignment = .center,
        @ViewBuilder content: (T) -> V,
        @ViewBuilder `else`: () -> V? = { nil }
    ) -> some View where V : View {
        self
            .background(alignment: alignment) {
                if let optional {
                    content(optional)
                } else {
                    `else`()
                }
            }
    }
}
