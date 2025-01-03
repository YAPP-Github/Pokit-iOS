//
//  CategorySharingView.swift
//  Feature
//
//  Created by 김도형 on 8/21/24.

import SwiftUI

import ComposableArchitecture
import FeatureContentCard
import Domain
import DSKit

@ViewAction(for: CategorySharingFeature.self)
public struct CategorySharingView: View {
    /// - Properties
    @Perception.Bindable
    public var store: StoreOf<CategorySharingFeature>
    
    /// - Initializer
    public init(store: StoreOf<CategorySharingFeature>) {
        self.store = store
    }
}
//MARK: - View
public extension CategorySharingView {
    var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 16) {
                header(category: store.category)
                
                contentScrollView
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .pokitNavigationBar { navigationBar }
            .ignoresSafeArea(edges: .bottom)
            .onAppear { send(.뷰가_나타났을때, animation: .pokitDissolve) }
            .sheet(isPresented: $store.isErrorSheetPresented) {
                PokitAlert(
                    store.error?.title ?? "에러",
                    message: store.error?.message,
                    confirmText: "확인",
                    action: { send(.경고_확인버튼_눌렀을때) }
                )
            }
        }
    }
}
//MARK: - Configure View
private extension CategorySharingView {
    var navigationBar: some View {
        PokitHeader {
            PokitHeaderItems(placement: .leading) {
                PokitToolbarButton(
                    .icon(.arrowLeft),
                    action: { send(.dismiss) }
                )
            }
        }
        .padding(.top, 8)
    }
    
    @ViewBuilder
    func header(category: CategorySharing.Category) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(category.categoryName)
                    .foregroundStyle(.pokit(.text(.primary)))
                    .pokitFont(.title1)
                
                Text("링크 \(category.contentCount)개")
                    .foregroundStyle(.pokit(.text(.secondary)))
                    .pokitFont(.detail1)
            }
            
            Spacer()
            
            PokitTextButton(
                "저장하기",
                state: .filled(.primary),
                size: .medium,
                shape: .rectangle,
                action: { send(.저장_버튼_눌렀을때) }
            )
        }
    }
    
    var contentScrollView: some View {
        Group {
            if !store.isLoading {
                if store.contents.isEmpty {
                    VStack {
                        PokitCaution(type: .링크없음)
                        .padding(.top, 20)
                        
                        Spacer()
                    }
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 0) {
                            ForEach(
                                store.scope(state: \.contents, action: \.contents)
                            ) { store in
                                let isFirst = store.state.id == self.store.contents.first?.id
                                let isLast = store.state.id == self.store.contents.last?.id
                                
                                ContentCardView(
                                    store: store,
                                    type: .linkList,
                                    isFirst: isFirst,
                                    isLast: isLast
                                )
                            }
                            
                            if store.hasNext {
                                PokitLoading()
                                    .padding(.top, 12)
                                    .onAppear { send(.페이지_로딩중일때) }
                            }
                        }
                    }
                }
            } else {
                PokitLoading()
            }
        }
    }
}

//MARK: - Preview
import CoreKit
#Preview {
    CategorySharingView(
        store: Store(
            initialState: CategorySharingFeature.State(
                sharedCategory: SharedCategoryResponse.mock.toDomain()
            ),
            reducer: { CategorySharingFeature()._printChanges() }
        )
    )
}


