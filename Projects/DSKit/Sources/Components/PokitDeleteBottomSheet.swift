//
//  PokitDeleteBottomSheet.swift
//  DSKit
//
//  Created by 김민호 on 7/16/24.
//

import SwiftUI

public struct PokitDeleteBottomSheet: View {
    @State
    private var height: CGFloat = 0
    private let type: SheetType
    private let delegateSend: ((PokitDeleteBottomSheet.Delegate) -> Void)?
    
    public init(
        type: SheetType,
        delegateSend: ((PokitDeleteBottomSheet.Delegate) -> Void)?
    ) {
        self.type = type
        self.delegateSend = delegateSend
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            /// - 텍스트 영역
            VStack(spacing: 8) {
                Text(type.sheetTitle)
                    .foregroundStyle(.pokit(.text(.primary)))
                    .pokitFont(.title2)
                Text(type.sheetContents)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.pokit(.text(.secondary)))
                    .pokitFont(.b2(.m))
            }
            .padding(.top, 36)
            .padding(.bottom, 20)
            /// - 취소 / 삭제 버튼 영역
            HStack(spacing: 8) {
                PokitBottomButton(
                    "취소",
                    state: .default(.primary),
                    action: { delegateSend?(.cancelButtonTapped) }
                )
                
                PokitBottomButton(
                    "삭제",
                    state: .filled(.primary),
                    action: { delegateSend?(.deleteButtonTapped) }
                )
            }
        }
        .padding(.horizontal, 20)
        .background(.white)
        .pokitPresentationCornerRadius()
        .pokitPresentationBackground()
        .presentationDragIndicator(.visible)
        .readHeight()
        .onPreferenceChange(HeightPreferenceKey.self) { height in
            if let height {
                self.height = height
            }
        }
        .presentationDetents([.height(self.height)])
    }
}
//MARK: - Delegate
public extension PokitDeleteBottomSheet {
    enum SheetType {
        case 링크삭제
        case 포킷삭제
        
        var sheetTitle: String {
            switch self {
            case .링크삭제: "링크를 정말 삭제하시겠습니까?"
            case .포킷삭제: "포킷을 정말 삭제하시겠습니까?"
            }
        }
        
        var sheetContents: String {
            switch self {
            case .링크삭제:
                return "함께 저장한 모든 정보가 삭제되며,\n복구하실 수 없습니다."
            case .포킷삭제:
                return "함께 저장한 모든 포킷이 삭제되며,\n복구하실 수 없습니다."
            }
        }
    }
    enum Delegate {
        /// 취소버튼 눌렀을 때
        case cancelButtonTapped
        /// 삭제버튼 눌렀을 때
        case deleteButtonTapped
    }
}

#Preview {
    PokitDeleteBottomSheet(
        type: .포킷삭제,
        delegateSend: nil
    )
}
