//
//  SelectFieldView.swift
//  Feature
//
//  Created by 김도형 on 7/5/24.

import ComposableArchitecture
import SwiftUI

import DSKit

@ViewAction(for: SelectFieldFeature.self)
public struct SelectFieldView: View {
    /// - Properties
    @Perception.Bindable
    public var store: StoreOf<SelectFieldFeature>
    /// - Initializer
    public init(store: StoreOf<SelectFieldFeature>) {
        self.store = store
    }
}
//MARK: - View
public extension SelectFieldView {
    var body: some View {
        WithPerceptionTracking {
            VStack(alignment: .leading, spacing: 0) {
                Group {
                    title
                        .padding(.top, 16)
                    
                    fieldsFlow
                        .padding(.top, 36)
                }
                
                Spacer()
                
                PokitBottomButton(
                    "다음",
                    state: store.selectedFields.count == 0 ? .disable : .filled(.primary),
                    action: { send(.nextButtonTapped) }
                )
            }
            .padding(.horizontal, 20)
            .background(.pokit(.bg(.base)))
            .ignoresSafeArea(edges: .bottom)
            .pokitNavigationBar(title: "")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    PokitToolbarButton(.icon(.arrowLeft)) {
                        send(.backButtonTapped)
                    }
                }
            }
            .task { await send(.onAppear).finish() }
        }
    }
}
//MARK: - Configure View
extension SelectFieldView {
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
    
    private var fieldsFlow: some View {
        PokitFlowLayout(rowSpacing: 12, colSpacing: 10) {
            ForEach(store.fields, id: \.self) { field in
                let isSelected = store.selectedFields.contains(field)
                let isMaxCount = store.selectedFields.count >= 3
                
                PokitTextChip(
                    field,
                    state: isSelected ? .filled(.primary) : isMaxCount ? .disable : .default(.primary),
                    size: .medium
                ) {
                    send(.fieldChipTapped(field), animation: .smooth)
                }
            }
            .animation(.pokitSpring, value: store.fields)
        }
    }
}
//MARK: - Preview
#Preview {
    NavigationStack {
        SelectFieldView(
            store: Store(
                initialState: .init(nickname: ""),
                reducer: { SelectFieldFeature() }
            )
        )
    }
}


