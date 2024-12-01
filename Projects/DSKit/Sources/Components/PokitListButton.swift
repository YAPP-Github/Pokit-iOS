//
//  PokitListButton.swift
//  DSKit
//
//  Created by 김도형 on 12/1/24.
//

import SwiftUI

public struct PokitListButton: View {
    @Binding
    private var isOn: Bool
    
    private let title: String
    private let type: PokitListButton.ListButtonType
    private let action: () -> Void
    
    public init(
        title: String,
        type: PokitListButton.ListButtonType,
        isOn: Binding<Bool> = .constant(false),
        action: @escaping () -> Void
    ) {
        self.title = title
        self.type = type
        self._isOn = isOn
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            label
        }
    }
    
    private var label: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                switch type {
                case let .default(icon),
                    let .bottomSheet(icon),
                    let .subText(icon, _):
                    Text(title)
                        .pokitFont(.b1(.m))
                        .foregroundStyle(.pokit(.text(.secondary)))
                    
                    Spacer()
                    
                    Image(icon)
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(.pokit(.icon(.primary)))
                case .toggle:
                    Toggle(isOn: $isOn) {
                        Text(title)
                            .pokitFont(.b1(.m))
                            .foregroundStyle(.pokit(.text(.secondary)))
                    }
                    .tint(.pokit(.icon(.brand)))
                }
                
            }
            
            if case let .subText(_, subeText) = type {
                Text(subeText)
                    .pokitFont(.detail1)
                    .foregroundStyle(.pokit(.text(.tertiary)))
                    .lineLimit(1)
            }
            
            if case let .toggle(subeText) = type {
                Text(subeText)
                    .pokitFont(.detail1)
                    .foregroundStyle(.pokit(.text(.tertiary)))
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(alignment: .bottom) {
            if case .bottomSheet = type {
                Rectangle()
                    .fill(.pokit(.border(.tertiary)))
                    .frame(height: 1)
            }
        }
    }
}

extension PokitListButton {
    public enum ListButtonType {
        case `default`(icon: PokitImage)
        case bottomSheet(icon: PokitImage)
        case subText(icon: PokitImage, subeText: String)
        case toggle(subeText: String)
        
    }
}

@available(iOS 18.0, *)
#Preview {
    @Previewable
    @State var isOn: Bool = false
    
    PokitListButton(
        title: "공지사항",
        type: .default(icon: .icon(.arrowRight)),
        action: { }
    )
    
    PokitListButton(
        title: "공지사항",
        type: .bottomSheet(icon: .icon(.edit)),
        action: { }
    )
    
    PokitListButton(
        title: "공지사항",
        type: .subText(
            icon: .icon(.arrowRight),
            subeText: "포킷에 저장된 링크가 다른 사용자에게 추천됩니다."
        ),
        action: { }
    )
    
    PokitListButton(
        title: "공지사항",
        type: .toggle(subeText: "포킷에 저장된 링크가 다른 사용자에게 추천됩니다."),
        isOn: $isOn,
        action: { }
    )
}
