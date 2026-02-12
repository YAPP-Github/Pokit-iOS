//
//  PokitDeleteBottomSheet.swift
//  DSKit
//
//  Created by 김민호 on 7/16/24.
//

import SwiftUI

public struct PokitDeleteBottomSheet: View {
    @State
    private var height: CGFloat = 246
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
        GeometryReader { proxy in
            let bottomSafeArea = proxy.safeAreaInsets.bottom
            let topSafeArea = proxy.safeAreaInsets.top

            VStack(spacing: 0) {
                /// - 텍스트 영역
                VStack(spacing: 8) {
                    Text(type.sheetTitle)
                        .foregroundStyle(.pokit(.text(.primary)))
                        .pokitFont(.title2)
                    
                    Text(type.sheetContents)
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
                        type.confirmButtonTitle,
                        state: .filled(.primary),
                        action: { delegateSend?(.deleteButtonTapped) }
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 36 - bottomSafeArea)
            .padding(.top, 12 - topSafeArea)
            .ignoresSafeArea(edges: [.bottom, .top])
            .readHeight()
            .onPreferenceChange(HeightPreferenceKey.self) { height in
                if let height {
                    self.height = height
                }
            }
            .onAppear {
                UINotificationFeedbackGenerator()
                    .notificationOccurred(.warning)
            }
        }
        .pokitPresentationCornerRadius()
        .pokitPresentationBackground()
        .presentationDragIndicator(.visible)
        .presentationDetents([.height(height)])
    }
}
//MARK: - Delegate
public extension PokitDeleteBottomSheet {
    enum SheetType {
        case 링크삭제
        case 포킷삭제
        case 유저내보내기(String)
        case 포킷나가기

        var sheetTitle: String {
            switch self {
            case .링크삭제: "링크를 정말 삭제하시겠습니까?"
            case .포킷삭제: "포킷을 정말 삭제하시겠습니까?"
            case .유저내보내기: "유저를 내보내시겠습니까?"
            case .포킷나가기: "포킷을 나가시겠습니까?"
            }
        }

        var sheetContents: String {
            switch self {
            case .링크삭제:
                return "함께 저장한 모든 정보가 삭제되며,\n복구하실 수 없습니다."
            case .포킷삭제:
                return "함께 저장한 모든 링크가 삭제되며,\n복구하실 수 없습니다."
            case .유저내보내기(let nickname):
                return "선택한 유저를 함께 공유 중인 포킷에서\n내보내시겠습니까?"
            case .포킷나가기:
                return "포킷을 나가면 해당 포킷이\n목록에서 사라집니다."
            }
        }

        var confirmButtonTitle: String {
            switch self {
            case .링크삭제, .포킷삭제: "삭제"
            case .유저내보내기: "내보내기"
            case .포킷나가기: "나가기"
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
