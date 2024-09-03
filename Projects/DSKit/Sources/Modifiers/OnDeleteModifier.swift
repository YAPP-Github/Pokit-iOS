//
//  OnDeleteModifier.swift
//  DSKit
//
//  Created by 김민호 on 7/22/24.
//

import SwiftUI

private struct OnDeleteModifier: ViewModifier {
    var deleteAction: () -> Void
    
    func body(content: Content) -> some View {
        content
            .swipeActions(edge: .trailing) {
                Button(role: .destructive, action: { deleteAction() }) {
                    VStack(spacing: 0) {
                        Image(.icon(.trash))
                            .frame(width: 24, height: 24)
                        Text("삭제")
                            .pokitFont(.b3(.b))
                            .foregroundStyle(.pokit(.text(.inverseWh)))
                    }
                }
                .tint(.red)
            }
    }
}

public extension View {
    func onDelete(deleteAction: @escaping () -> Void) -> some View {
        self.modifier(OnDeleteModifier(deleteAction: deleteAction))
    }
}
