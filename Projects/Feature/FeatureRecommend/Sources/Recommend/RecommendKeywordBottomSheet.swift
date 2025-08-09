//
//  RecommendKeywordBottomSheet.swift
//  FeatureRecommend
//
//  Created by 김도형 on 2/22/25.
//

import SwiftUI

import Domain
import DSKit
import Util

struct RecommendKeywordBottomSheet: View {
    @State
    private var selectedInterests: Set<BaseInterest>
    @State
    private var height: CGFloat = 0
    
    private let interests: [BaseInterest]
    private let onSave: ((Set<BaseInterest>) -> Void)?
    
    private init(
        selectedInterests: Set<BaseInterest>,
        interests: [BaseInterest],
        onSave: ((Set<BaseInterest>) -> Void)?
    ) {
        self._selectedInterests = State(wrappedValue: selectedInterests)
        self.interests = interests
        self.onSave = onSave
    }
    
    init(
        selectedInterests: Set<BaseInterest>,
        interests: [BaseInterest]
    ) {
        self._selectedInterests = State(wrappedValue: selectedInterests)
        self.interests = interests
        self.onSave = nil
    }
    
    
    var body: some View {
        VStack(spacing: 0) {
            title
                .padding(.top, 52)
                .pokitMaxWidth()
            
            fieldsFlow
                .padding(.top, 36)
                .padding(.bottom, 40)
            
            PokitBottomButton(
                "키워드 저장",
                state: selectedInterests.count == 0 ? .disable : .filled(.primary),
                action: { onSave?(selectedInterests) }
            )
            .pokitMaxWidth()
        }
        .padding(.horizontal, 20)
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
        .onDisappear { onSave?(selectedInterests) }
    }
    
    func onSave(_ perform: @escaping (Set<BaseInterest>) -> Void) -> Self {
        RecommendKeywordBottomSheet(
            selectedInterests: self.selectedInterests,
            interests: self.interests,
            onSave: perform
        )
    }
}

//MARK: - Configure View
extension RecommendKeywordBottomSheet {
    private var title: some View {
        HStack {
            VStack(alignment: .leading, spacing: 12) {
                Text("관심 키워드를 선택해 주세요")
                    .pokitFont(.title1)
                    .foregroundStyle(.pokit(.text(.primary)))
                
                Text("최대 3개의 관심 키워드를 선택하시면\n관련 링크가 추천됩니다")
                    .pokitFont(.title3)
                    .foregroundStyle(.pokit(.text(.secondary)))
            }
            
            Spacer()
        }
    }
    
    private var fieldsFlow: some View {
        PokitFlowLayout(rowSpacing: 12, colSpacing: 10) {
            ForEach(interests, id: \.self) { field in
                let isSelected = selectedInterests.contains(field)
                let isMaxCount = selectedInterests.count >= 3
                
                PokitTextChip(
                    field.description,
                    state: isSelected
                    ? .filled(.primary)
                    : isMaxCount ? .disable : .default(.primary),
                    size: .medium
                ) {
                    if isSelected {
                        selectedInterests.remove(field)
                    } else {
                        selectedInterests.insert(field)
                    }
                }
            }
            .animation(.pokitDissolve, value: selectedInterests)
        }
    }
}

@available(iOS 18.0, *)
#Preview {
    @Previewable
    @State
    var selectedInterests = Set<BaseInterest>()
    
    RecommendKeywordBottomSheet(
        selectedInterests: selectedInterests,
        interests: []
    )
}
