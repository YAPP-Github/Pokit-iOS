//
//  CategoryDetailView.swift
//  Feature
//
//  Created by 김민호 on 7/17/24.

import SwiftUI

import ComposableArchitecture
import Domain
import DSKit
import Util

@ViewAction(for: CategoryDetailFeature.self)
public struct CategoryDetailView: View {
    /// - Properties
    @Perception.Bindable
    public var store: StoreOf<CategoryDetailFeature>
    
    /// - Initializer
    public init(store: StoreOf<CategoryDetailFeature>) {
        self.store = store
    }
}
//MARK: - View
public extension CategoryDetailView {
    var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 16) {
                header
                contentScrollView
            }
            .padding(.top, 12)
            .padding(.horizontal, 20)
            .background(.pokit(.bg(.base)))
            .navigationBarBackButtonHidden()
            .toolbar { self.navigationBar }
            .sheet(isPresented: $store.isCategorySheetPresented) {
                PokitBottomSheet(
                    items: [.share, .edit, .delete],
                    height: 224,
                    delegateSend: { store.send(.scope(.categoryBottomSheet($0))) }
                )
            }
            .sheet(isPresented: $store.isCategorySelectSheetPresented) {
                PokitCategorySheet(
                    selectedItem: nil,
                    list: store.categories.elements,
                    action: { send(.categorySelected($0)) }
                )
                .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $store.isPokitDeleteSheetPresented) {
                PokitDeleteBottomSheet(
                    type: store.kebobSelectedType ?? .포킷삭제,
                    delegateSend: { store.send(.scope(.categoryDeleteBottomSheet($0))) }
                )
            }
            .sheet(isPresented: $store.isFilterSheetPresented) {
                CategoryFilterSheet(
                    sortType: store.sortType,
                    isBookMarkSelected: store.isFavoriteFiltered,
                    isUnreadSeleected: store.isUnreadFiltered,
                    delegateSend: { store.send(.scope(.filterBottomSheet($0))) }
                )
            }
            .onAppear { send(.onAppear) }
        }
    }
}
//MARK: - Configure View
private extension CategoryDetailView {
    @ToolbarContentBuilder
    var navigationBar: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            PokitToolbarButton(
                .icon(.arrowLeft),
                action: { send(.dismiss) }
            )
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            PokitToolbarButton(.icon(.kebab), action: { send(.categoryKebobButtonTapped(.포킷삭제, selectedItem: nil)) })
        }
    }
    
    var header: some View {
        VStack(spacing: 4) {
            HStack(spacing: 8) {
                /// cateogry title
                Button(action: { send(.categorySelectButtonTapped) }) {
                    Text(store.category.categoryName)
                        .foregroundStyle(.pokit(.text(.primary)))
                        .pokitFont(.title1)
                    Image(.icon(.arrowDown))
                        .resizable()
                        .frame(width: 24, height: 24)
                    Spacer()
                }
                .buttonStyle(.plain)
            }
            HStack {
                Text("링크 \(store.category.contentCount)개")
                Spacer()
                PokitIconLButton(
                    "필터",
                    .icon(.filter),
                    state: .filled(.primary),
                    size: .small,
                    shape: .round,
                    action: { send(.filterButtonTapped) }
                )
            }
        }
    }
    
    var contentScrollView: some View {
        ScrollView(showsIndicators: false) {
            ForEach(store.contents) { content in
                let isFirst = content == store.contents.first
                let isLast = content == store.contents.last
                
                PokitLinkCard(
                    link: content,
                    action: { send(.contentItemTapped(content)) }, 
                    kebabAction: { send(.categoryKebobButtonTapped(.링크삭제, selectedItem: content)) }
                )
                .divider(isFirst: isFirst, isLast: isLast)
                .pokitScrollTransition(.opacity)
            }
        }
        .animation(.spring, value: store.contents.elements)
    }
    
    struct PokitCategorySheet: View {
        @State private var height: CGFloat = 0
        var action: (BaseCategoryItem) -> Void
        var selectedItem: BaseCategoryItem?
        var list: [BaseCategoryItem]
        
        public init(
            selectedItem: BaseCategoryItem?,
            list: [BaseCategoryItem],
            action: @escaping (BaseCategoryItem) -> Void
        ) {
            self.selectedItem = selectedItem
            self.list = list
            self.action = action
        }
        
        var body: some View {
            PokitList(
                selectedItem: selectedItem,
                list: list,
                action: action
            )
        }
    }
}
//MARK: - Preview
#Preview {
    NavigationStack {
        CategoryDetailView(
            store: Store(
                initialState: .init(
                    category: .init(
                        id: 0,
                        userId: 0,
                        categoryName: "포킷",
                        categoryImage: .init(imageId: 0, imageURL: ""),
                        contentCount: 16
                    )
                ),
                reducer: { CategoryDetailFeature() }
            )
        )
    }
}


