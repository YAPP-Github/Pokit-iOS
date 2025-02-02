//
//  PokitKeywordBottomSheet.swift
//  Feature
//
//  Created by 김민호 on 1/23/25.
//

import SwiftUI

import DSKit
import Util

public struct PokitKeywordBottomSheet: View {
    @State
    private var height: CGFloat = 0
    @State
    private var selectedKeywordType: BaseInterestType
    @State
    private var keywordSheetBottomButtonState: PokitButtonStyle.State = .disable
    private let action: (BaseInterestType) -> Void
    
    public init(
        selectedKeywordType: BaseInterestType,
        action: @escaping (BaseInterestType) -> Void
    ) {
        self.selectedKeywordType = selectedKeywordType
        self.keywordSheetBottomButtonState = selectedKeywordType == .default
        ? .disable
        : .filled(.primary)
        self.action = action
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("포킷의 키워드를 선택해 주세요")
                .pokitFont(.title1)
                .foregroundStyle(.pokit(.text(.primary)))
            Text("키워드 기반으로 다른 사용자에게\n링크가 추천됩니다")
                .pokitFont(.title3)
                .foregroundStyle(.pokit(.text(.secondary)))
                .padding(.top, 12)
            PokitFlowLayout(rowSpacing: 12, colSpacing: 10) {
                ForEach(BaseInterestType.allCases, id: \.self) { field in
                    let isSelected = selectedKeywordType != .default
                    if field != .default {
                        PokitTextChip(
                            field.title,
                            state: isSelected && field == selectedKeywordType
                            ? .filled(.primary)
                            : .default(.primary),
                            size: .medium
                        ) {
                            selectedKeywordType = field
                        }
                    }
                }
                .animation(.pokitDissolve, value: selectedKeywordType)
            }
            .padding(.top, 36)
            .padding(.bottom, 40)
            
            PokitBottomButton(
                "키워드 선택",
                state: keywordSheetBottomButtonState,
                action: { action(selectedKeywordType) }
            )
            .padding(.top, 16)
        }
        .padding(.horizontal, 20)
        .padding(.top, 48)
        .onChange(of: selectedKeywordType) { _ in
            keywordSheetBottomButtonState = .filled(.primary)
        }
        .background(.pokit(.bg(.base)))
        .pokitPresentationCornerRadius()
        .pokitPresentationBackground()
        .presentationDragIndicator(.visible)
        .readHeight()
        .onPreferenceChange(HeightPreferenceKey.self) { height in
            if let height {
                self.height = height
            }
        }
        .presentationDetents([.height(height)])
        .ignoresSafeArea(edges: [.bottom, .top])
    }
}

#Preview {
    ZStack {
        Color.black
            .sheet(isPresented: .constant(true)) {
                PokitKeywordBottomSheet(
                    selectedKeywordType: .default,
                    action: { _ in }
                )
            }
    }
}


