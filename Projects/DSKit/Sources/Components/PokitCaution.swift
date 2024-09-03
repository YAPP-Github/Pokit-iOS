//
//  PokitCaution.swift
//  DSKit
//
//  Created by 김도형 on 8/10/24.
//

import SwiftUI

public struct PokitCaution: View {
    private let image: PokitImage.Character
    private let titleKey: String
    private let message: String
    private let action: (() -> Void)?
    
    public init(
        image: PokitImage.Character,
        titleKey: String,
        message: String,
        action: (() -> Void)? = nil
    ) {
        self.image = image
        self.titleKey = titleKey
        self.message = message
        self.action = action
    }
    
    public var body: some View {
        HStack {
            Spacer()
            
            VStack(spacing: 0) {
                Image(.character(image))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 180, height: 180)
                    .padding(.bottom, 16)
                
                Text(titleKey)
                    .pokitFont(.title2)
                    .foregroundStyle(.pokit(.text(.secondary)))
                    .padding(.bottom, 8)
                
                Text(message)
                    .pokitFont(.b2(.m))
                    .foregroundStyle(.pokit(.text(.secondary)))
                    .padding(.bottom, 16)
                
                if let action {
                    PokitTextButton(
                        "다시시도",
                        state: .default(.secondary),
                        size: .small,
                        shape: .rectangle,
                        action: action
                    )
                }
            }
            
            Spacer()
        }
    }
}

#Preview {
    PokitCaution(
        image: .empty,
        titleKey: "저장된 포킷이 없어요!",
        message: "포킷을 생성해 링크를 저장해보세요",
        action: {}
    )
}
