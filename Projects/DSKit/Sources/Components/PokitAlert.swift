//
//  PokitAlert.swift
//  DSKit
//
//  Created by 김도형 on 7/10/24.
//

import SwiftUI

public struct PokitAlert: View {
    @Environment(\.dismiss) private var dismiss
    @State private var height: CGFloat = 0
    private let titleKey: String
    private let message: String?
    private let confirmText: String
    private let action: () -> Void
    private let cancelAction: (() -> Void)?
    
    public init(
        _ titleKey: String,
        message: String? = nil,
        confirmText: String,
        action: @escaping () -> Void,
        cancelAction: (() -> Void)? = nil
    ) {
        self.titleKey = titleKey
        self.message = message
        self.confirmText = confirmText
        self.action = action
        self.cancelAction = cancelAction
    }
    
    public var body: some View {
        GeometryReader { proxy in
            let bottomSafeArea = proxy.safeAreaInsets.bottom
            VStack(spacing: 0) {
                VStack(spacing: 8) {
                    title
                    
                    if message != nil {
                        messageLabel
                    }
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
                        cancelAction?()
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
                .pokitMaxWidth()
            }
            .pokitPresentationBackground()
            .pokitPresentationCornerRadius()
            .presentationDragIndicator(.visible)
            .padding(.bottom, 36 - bottomSafeArea)
            .readHeight()
            .onPreferenceChange(HeightPreferenceKey.self) { height in
                if let height {
                    self.height = height
                }
            }
            .presentationDetents([.height(self.height)])
            .onAppear {
                UINotificationFeedbackGenerator()
                    .notificationOccurred(.warning)
            }
        }
    }
    
    private var title: some View {
        Text(titleKey)
            .pokitFont(.title2)
            .foregroundStyle(.pokit(.text(.primary)))
            .multilineTextAlignment(.center)
    }
    
    private var messageLabel: some View {
        Text(message ?? "")
            .pokitFont(.b2(.m))
            .foregroundStyle(.pokit(.text(.secondary)))
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
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
