//
//  PokitAlert.swift
//  DSKit
//
//  Created by 김도형 on 7/10/24.
//

import SwiftUI

public struct PokitAlert: View {
    @Environment(\.dismiss) private var dismiss
    
    private let titleKey: String
    private let message: String
    private let confirmText: String
    private let action: () -> Void
    
    public init(
        _ titleKey: String,
        message: String,
        confirmText: String,
        action: @escaping () -> Void
    ) {
        self.titleKey = titleKey
        self.message = message
        self.confirmText = confirmText
        self.action = action
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                title
                
                messageLabel
            }
            .padding(.top, 36)
            .padding(.bottom, 20)
            
            PokitBottomSwitchRadio {
                PokitPartSwitchRadio(
                    labelText: "취소",
                    selection: .constant(false),
                    to: true,
                    style: .stroke
                ) {
                    dismiss()
                }
                .background()
                
                PokitPartSwitchRadio(
                    labelText: confirmText,
                    selection: .constant(true),
                    to: true,
                    style: .filled,
                    action: action
                )
                .background()
            }
        }
        .presentationDetents([.height(238)])
        .pokitPresentationBackground()
        .pokitPresentationCornerRadius()
    }
    
    private var title: some View {
        Text(titleKey)
            .pokitFont(.title2)
            .foregroundStyle(.pokit(.text(.primary)))
            .multilineTextAlignment(.center)
    }
    
    private var messageLabel: some View {
        Text(message)
            .pokitFont(.b2(.m))
            .foregroundStyle(.pokit(.text(.secondary)))
            .multilineTextAlignment(.center)
    }
}

#Preview {
    VStack {
        Spacer()
    }
    .sheet(isPresented: .constant(true)) {
        PokitAlert(
            "링크를 정말 삭제하시겠습니까?",
            message: "함께 저장한 모든 정보가 삭제되며,\n복구하실 수 없습니다.",
            confirmText: "삭제",
            action: {}
        )
    }
}
