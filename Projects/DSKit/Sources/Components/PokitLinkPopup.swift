//
//  PokitLinkPopUp.swift
//  DSKit
//
//  Created by 김도형 on 7/22/24.
//

import SwiftUI
import Combine

public struct PokitLinkPopup: View {
    @Binding private var isPresented: Bool
    
    @State private var second: Int = 0
    private let titleKey: String
    private let type: PokitLinkPopup.PopupType
    private let action: (() -> Void)?
    private let timer = Timer.publish(
        every: 1,
        on: .main,
        in: .common
    ).autoconnect()
    
    public init(
        _ titleKey: String,
        isPresented: Binding<Bool>,
        type: PokitLinkPopup.PopupType,
        action: (() -> Void)? = nil
    ) {
        self.titleKey = titleKey
        self._isPresented = isPresented
        self.type = type
        self.action = action
    }
    
    public var body: some View {
        ZStack {
            background
            
            popup
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
        }
        .frame(width: 335, height: 60)
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .onReceive(timer) { _ in
            guard second < 2 && isPresented else {
                closedPopup()
                return
            }
            second += 1
        }
    }
    
    private var popup: some View {
        HStack(spacing: 0) {
            Button {
                action?()
            } label: {
                VStack(alignment: .leading, spacing: 0) {
                    Text(titleKey)
                        .lineLimit(2)
                        .pokitFont(.b2(.b))
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(
                            type == .warning
                            ? .pokit(.text(.primary))
                            : .pokit(.text(.inverseWh))
                        )
                    
                    if case .link(let url) = type {
                        Text(url)
                            .lineLimit(1)
                            .pokitFont(.detail2)
                            .foregroundStyle(.pokit(.text(.inverseWh)))
                    }
                }
                
                if case .success = type {
                    Image(.icon(.check))
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(.pokit(.icon(.inverseWh)))
                }
                
                Spacer(minLength: 72)
            }
            
            closeButton
        }
    }
    
    private var background: some View {
        RoundedRectangle(cornerRadius: 9999, style: .continuous)
            .fill(backgroundColor)
    }
    
    private var closeButton: some View {
        Button(action: closedPopup) {
            Image(.icon(.x))
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundStyle(
                    type == .warning
                    ? .pokit(.icon(.primary))
                    : .pokit(.icon(.inverseWh))
                )
        }
    }
    
    private func closedPopup() {
        withAnimation(.pokitSpring) {
            second = 0
            isPresented = false
        }
    }
    
    private var backgroundColor: Color {
        switch type {
        case .link, .text:
            return .pokit(.bg(.tertiary))
        case .success:
            return .pokit(.bg(.success))
        case .error:
            return .pokit(.bg(.error))
        case .warning:
            return .pokit(.bg(.warning))
        }
    }
}

public extension PokitLinkPopup {
    enum PopupType: Equatable {
        case link(url: String)
        case text
        case success
        case error
        case warning
    }
}

#Preview {
    VStack {
        PokitLinkPopup(
            "복사한 링크 저장하기",
            isPresented: .constant(true),
            type: .link(url: "https://www.youtube.com/watch?v=xSTwqKUyM8k")
        )
        
        PokitLinkPopup(
            "최대 30개의 포킷을 생성할 수 있습니다.\n포킷을 삭제한 뒤에 추가해주세요.",
            isPresented: .constant(true),
            type: .text
        )
        
        PokitLinkPopup(
            "링크저장 완료",
            isPresented: .constant(true),
            type: .success
        )
        
        PokitLinkPopup(
            "링크저장 실패",
            isPresented: .constant(true),
            type: .error
        )
        
        PokitLinkPopup(
            "저장공간 부족",
            isPresented: .constant(true),
            type: .warning
        )
    }
}
