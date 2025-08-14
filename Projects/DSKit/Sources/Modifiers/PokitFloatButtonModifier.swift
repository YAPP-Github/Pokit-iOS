//
//  PokitFloatButtonModifier.swift
//  DSKit
//
//  Created by 김민호 on 1/16/25.
//
import SwiftUI

private struct PokitFloatButtonModifier: ViewModifier {
    let action: () -> Void
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottomTrailing) {
                Button(action: action) {
                    Image(.icon(.plus))
                        .resizable()
                        .frame(width: 36, height: 36)
                        .padding(12)
                        .foregroundStyle(.pokit(.icon(.inverseWh)))
                        .background {
                            RoundedRectangle(cornerRadius: 9999, style: .continuous)
                                .fill(.pokit(.bg(.brand)))
                        }
                        .frame(width: 60, height: 60)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 39)
            }
    }
}

public extension View {
    func pokitFloatButton(action: @escaping () -> Void) -> some View {
        return self.modifier(PokitFloatButtonModifier(action: action))
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
            .pokitFloatButton(action: {})
    }
}
