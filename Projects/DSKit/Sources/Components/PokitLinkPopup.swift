//
//  PokitLinkPopUp.swift
//  DSKit
//
//  Created by 김도형 on 7/22/24.
//

import SwiftUI
import Combine

public struct PokitLinkPopup: View {
    @Binding
    private var type: PokitLinkPopup.PopupType?
    
    @State
    private var second: Int = 0
    private let action: (() -> Void)?
    private let timer = Timer.publish(
        every: 1,
        on: .main,
        in: .common
    ).autoconnect()
    
    public init(
        type: Binding<PokitLinkPopup.PopupType?>,
        action: (() -> Void)? = nil
    ) {
        self._type = type
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
            guard second < 2 else {
                closedPopup()
                return
            }
            second += 1
        }
        .onAppear(perform: feedback)
    }
    
    private var popup: some View {
        HStack(spacing: 0) {
            Button {
                action?()
            } label: {
                VStack(alignment: .leading, spacing: 0) {
                    Text(title)
                        .lineLimit(2)
                        .pokitFont(.b2(.b))
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(textColor)
                    
                    if case let .link(_, url) = type {
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
                .foregroundStyle(iconColor)
        }
    }
    
    private func closedPopup() {
        withAnimation(.pokitSpring) {
            type = nil
            second = 0
        }
    }
    
    private func feedback() {
        switch type {
        case .link, .text, .warning:
            UINotificationFeedbackGenerator()
                .notificationOccurred(.warning)
        case .success:
            UINotificationFeedbackGenerator()
                .notificationOccurred(.success)
        case .error:
            UINotificationFeedbackGenerator()
                .notificationOccurred(.error)
        case .none: break
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
        case .none: return .clear
        }
    }
    
    private var iconColor: Color {
        switch type {
        case .warning:
            return .pokit(.icon(.primary))
        default:
            return .pokit(.icon(.inverseWh))
        }
    }
    
    private var textColor: Color {
        switch type {
        case .warning:
            return .pokit(.text(.primary))
        default:
            return .pokit(.text(.inverseWh))
        }
    }
    
    private var title: String {
        switch type {
        case let .link(title, _),
             let .text(title),
             let .success(title),
             let .error(title),
             let .warning(title):
            return title
        default: return ""
        }
    }
}

public extension PokitLinkPopup {
    enum PopupType: Equatable {
        case link(title: String, url: String)
        case text(title: String)
        case success(title: String)
        case error(title: String)
        case warning(title: String)
    }
}

#Preview {
    VStack {
        PokitLinkPopup(
            type: .constant(.link(
                title: "복사한 링크 저장하기",
                url: "https://www.youtube.com/watch?v=xSTwqKUyM8k"
            ))
        )
        
        PokitLinkPopup(
            type: .constant(.text(title: "최대 30개의 포킷을 생성할 수 있습니다.\n포킷을 삭제한 뒤에 추가해주세요."))
        )
        
        PokitLinkPopup(
            type: .constant(.success(title: "링크저장 완료"))
        )
        
        PokitLinkPopup(
            type: .constant(.error(title: "링크저장 실패"))
        )
        
        PokitLinkPopup(
            type: .constant(.warning(title: "저장공간 부족"))
        )
    }
}
