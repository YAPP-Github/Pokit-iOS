//
//  CategorySharingView.swift
//  Feature
//
//  Created by 김도형 on 8/21/24.

import SwiftUI

import ComposableArchitecture
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
            .sheet(item: $store.alert) { alert in
                PokitAlert(
                    alert.titleKey,
                    message: alert.message,
                    confirmText: "확인",
                    action: { send(.경고_확인버튼_클릭) }
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
                    action: { send(.뒤로가기버튼_클릭) }
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
                action: { send(.저장버튼_클릭) }
            )
        }
    }
    
    var contentScrollView: some View {
        Group {
            if let contents = store.contents {
                if contents.isEmpty {
                    VStack {
                        PokitCaution(
                            image: .empty,
                            titleKey: "저장된 링크가 없어요!",
                            message: "다양한 링크를 한 곳에 저장해보세요"
                        )
                        .padding(.top, 20)
                        
                        Spacer()
                    }
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 0) {
                            ForEach(contents) { content in
                                let isFirst = content == contents.first
                                let isLast = content == contents.last
                                
                                PokitLinkCard(
                                    link: content,
                                    action: { send(.컨텐츠_아이템_클릭(content)) }
                                )
                                .divider(isFirst: isFirst, isLast: isLast)
                                .pokitScrollTransition(.opacity)
                            }
                            
                            if store.hasNext {
                                PokitLoading()
                                    .padding(.top, 12)
                                    .onAppear { send(.다음페이지_로딩_onAppear) }
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


