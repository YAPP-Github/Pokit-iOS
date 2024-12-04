//
//  View+Extension.swift
//  Util
//
//  Created by 김도형 on 12/1/24.
//

import SwiftUI

extension View {
    public func dismissKeyboard(
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
    
    public func dismissKeyboard<Value: Hashable>(
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
}
