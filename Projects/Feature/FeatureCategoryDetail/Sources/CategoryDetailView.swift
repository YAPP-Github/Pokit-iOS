//
//  CategoryDetailView.swift
//  Feature
//
//  Created by 김민호 on 7/17/24.

import SwiftUI

import ComposableArchitecture
import FeatureContentCard
import Domain
import DSKit
import Util
import NukeUI

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
            VStack(spacing: 24) {
                header
                PokitDivider().padding(.horizontal, -20)
                filterHeader
                contentScrollView
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .pokitNavigationBar { navigationBar }
            .pokitFloatButton(action: { send(.링크_추가_버튼_눌렀을때) })
            .ignoresSafeArea(edges: .bottom)
            .sheet(isPresented: $store.isCategorySheetPresented) {
                PokitBottomSheet(
                    items: [.edit, .delete],
                    delegateSend: { store.send(.scope(.categoryBottomSheet($0))) }
                )
            }
            .sheet(isPresented: $store.isCategorySelectSheetPresented) {
                if let categories = store.categories {
                    PokitCategorySheet(
                        selectedItem: nil,
                        list: categories.elements,
                        action: { send(.카테고리_선택했을때($0)) }
                    )
                    .presentationDragIndicator(.visible)
                } else {
                    PokitLoading()
                        .presentationDragIndicator(.visible)
                }
            }
            .sheet(isPresented: $store.isPokitDeleteSheetPresented) {
                PokitDeleteBottomSheet(
                    type: .포킷삭제,
                    delegateSend: { store.send(.scope(.categoryDeleteBottomSheet($0))) }
                )
            }
            .task { await send(.뷰가_나타났을때).finish() }
        }
    }
}
//MARK: - Configure View
private extension CategoryDetailView {
    var navigationBar: some View {
        PokitHeader {
            PokitHeaderItems(placement: .leading) {
                PokitToolbarButton(
                    .icon(.arrowLeft),
                    action: { send(.dismiss) }
                )
            }
            PokitHeaderItems(placement: .trailing) {
                PokitToolbarButton(
                    .icon(.kebab),
                    action: { send(.카테고리_케밥_버튼_눌렀을때) }
                )
            }
        }
        .padding(.top, 8)
    }
    
    @MainActor
    var header: some View {
        VStack(spacing: 0) {
            LazyImage(url: URL(string: store.category.categoryImage.imageURL)) { state in
                Group {
                    if let image = state.image {
                        image
                            .resizable()
                    } else {
                        PokitSpinner()
                            .foregroundStyle(.pokit(.icon(.brand)))
                    }
                }
                .frame(width: 100, height: 100)
                .animation(.pokitDissolve, value: state.image)
            }
            .padding(.bottom, 2)
            HStack(spacing: 8) {
                /// cateogry title
                Button(action: { send(.카테고리_선택_버튼_눌렀을때) }) {
                    Text(store.category.categoryName)
                        .foregroundStyle(.pokit(.text(.primary)))
                        .pokitFont(.title1)
                    Image(.icon(.arrowDown))
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(.pokit(.icon(.primary)))
                }
                .buttonStyle(.plain)
            }
            .padding(.bottom, 8)
            HStack(spacing: 3.5) {
                let iconColor: Color = .pokit(.icon(.secondary))
                let textColor: Color = .pokit(.text(.tertiary))
                
                if store.category.openType == .비공개 {
                    HStack(spacing: 2) {
                        Image(.icon(.lock))
                            .resizable()
                            .frame(width: 16, height: 16)
                            .foregroundStyle(iconColor)
                        Text("비밀")
                            .foregroundStyle(textColor)
                            .pokitFont(.b2(.m))
                    }
                }
                HStack(spacing: 2) {
                    Image(.icon(.link))
                        .resizable()
                        .frame(width: 16, height: 16)
                        .foregroundStyle(iconColor)
                    Text("\(store.contents.count)개")
                        .foregroundStyle(textColor)
                        .pokitFont(.b2(.m))
                }
                Text("#\(store.category.keywordType.title)")
                    .foregroundStyle(textColor)
                    .pokitFont(.b2(.m))
                    .padding(.leading, 4.5)
            }
            .padding(.bottom, 16)
            PokitIconLButton(
                "공유",
                .icon(.share),
                state: .filled(.primary),
                size: .medium,
                shape: .round,
                action: { send(.공유_버튼_눌렀을때) }
            )
        }
    }
    
    var filterHeader: some View {
        HStack(spacing: 8) {
            PokitTextButton(
                "즐겨찾기",
                state: store.isFavoriteFiltered
                ? .filled(.primary)
                : .default(.secondary),
                size: .small,
                shape: .round,
                action: { send(.분류_버튼_눌렀을때(.즐겨찾기)) }
            )
            PokitTextButton(
                "안읽음",
                state: store.isUnreadFiltered
                ? .filled(.primary)
                : .default(.secondary),
                size: .small,
                shape: .round,
                action: { send(.분류_버튼_눌렀을때(.안읽음)) }
            )
            
            Spacer()
            PokitIconLTextLink(
                store.sortType.title,
                icon: .icon(.align),
                action: { send(.정렬_버튼_눌렀을때) }
            )
            .contentTransition(.numericText())
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
                                Array(store.scope(state: \.contents, action: \.contents))
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
                                    .task { await send(.pagenation).finish() }
                            }
                            
                            Spacer()
                        }
                        .padding(.bottom, 36)
                    }
                }
            } else {
                PokitLoading()
            }
        }
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
                        categoryImage: .init(imageId: 0, imageURL: Constants.mockImageUrl),
                        contentCount: 16,
                        createdAt: "",
                        //TODO: v2 property 수정
                        openType: .비공개,
                        keywordType: .IT,
                        userCount: 0,
                        isFavorite: false
                    )
                ),
                reducer: { CategoryDetailFeature() }
            )
        )
    }
}


