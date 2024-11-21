//
//  PokitCaution.swift
//  DSKit
//
//  Created by 김도형 on 8/10/24.
//

import SwiftUI

public enum CautionType {
    case 카테고리없음
    case 미분류_링크없음
    case 링크없음
    case 즐겨찾기_링크없음
    case 링크부족
    case 알림없음
    
    var image: PokitImage.Character {
        switch self {
        case .카테고리없음, .링크없음, .즐겨찾기_링크없음, .미분류_링크없음:
            return .empty
        case .링크부족:
            return .sad
        case .알림없음:
            return .pooki
        }
    }
    
    var title: String {
        switch self {
        case .카테고리없음:
            return "저장된 포킷이 없어요!"
        case .미분류_링크없음:
            return "미분류 링크가 없어요!"
        case .링크없음:
            return "저장된 링크가 없어요!"
        case .즐겨찾기_링크없음:
            return "즐겨찾기 링크가 없어요!"
        case .링크부족:
            return "링크가 부족해요!"
        case .알림없음:
            return "알림이 없어요"
        }
    }
    
    var message: String {
        switch self {
        case .카테고리없음:
            return "포킷을 생성해 링크를 저장해보세요"
        case .미분류_링크없음:
            return "링크를 포킷에 깔끔하게 분류하셨어요"
        case .링크없음:
            return "다양한 링크를 한 곳에 저장해보세요"
        case .즐겨찾기_링크없음:
            return "링크를 즐겨찾기로 관리해보세요"
        case .링크부족:
            return "링크를 5개 이상 저장하고 추천을 받아보세요"
        case .알림없음:
            return "리마인드 알림을 설정하세요"
        }
    }
    
    var actionTitle: String? {
        switch self {
        case .카테고리없음:
            return "포킷 추가하기"
        case .미분류_링크없음:
            return "링크 추가하기"
        default: return nil
        }
    }
}

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
