//
//  SelectFieldView.swift
//  Feature
//
//  Created by 김도형 on 7/5/24.

import ComposableArchitecture
import SwiftUI
import DSKit

public struct SelectFieldView: View {
    /// - Properties
    private let store: StoreOf<SelectFieldFeature>
    /// - Initializer
    public init(store: StoreOf<SelectFieldFeature>) {
        self.store = store
    }
}
//MARK: - View
public extension SelectFieldView {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Group {
                title
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            PokitBottomButton(
                "다음",
                state: store.fields.count == 0 ? .disable : .filled(.primary)
            ) {
                
            }
        }
        .background(.pokit(.bg(.base)))
    }
    
    private var title: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("어떤 분야에 관심이 있으세요?")
                .pokitFont(.title1)
                .foregroundStyle(.pokit(.text(.primary)))
            
            Text("최대 3개를 골라주시면\n관련 콘텐츠를 추천해드릴게요!")
                .pokitFont(.title3)
                .foregroundStyle(.pokit(.text(.secondary)))
        }
    }
}
//MARK: - Configure View
extension SelectFieldView {
    
}
//MARK: - Preview
#Preview {
    SelectFieldView(
        store: Store(
            initialState: .init(),
            reducer: { SelectFieldFeature() }
        )
    )
}


