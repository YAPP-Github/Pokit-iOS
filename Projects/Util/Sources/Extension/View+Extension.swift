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
    func overlay(
        `if` condition: Bool,
        alignment: Alignment = .center,
        @ViewBuilder content: () -> some View,
        @ViewBuilder `else`: () -> some View = { EmptyView() }
    ) -> some View {
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
    func overlay<T>(
        ifLet optional: T?,
        alignment: Alignment = .center,
        @ViewBuilder content: (T) -> some View,
        @ViewBuilder `else`: () -> some View = { EmptyView() }
    ) -> some View {
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
    func background(
        `if` condition: Bool,
        alignment: Alignment = .center,
        @ViewBuilder content: () -> some View,
        @ViewBuilder `else`: () -> some View = { EmptyView() }
    ) -> some View {
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
    func background<T>(
        ifLet optional: T?,
        alignment: Alignment = .center,
        @ViewBuilder content: (T) -> some View,
        @ViewBuilder `else`: () -> some View = { EmptyView() }
    ) -> some View {
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
