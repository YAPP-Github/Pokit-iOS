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
    @State private var currentOffset: CGFloat = 0
    @State private var targetOffset: CGFloat = 0
    @State private var isSticky: Bool = false
    /// - Initializer
    public init(store: StoreOf<CategoryDetailFeature>) {
        self.store = store
    }
}
//MARK: - View
public extension CategoryDetailView {
    var body: some View {
        WithPerceptionTracking {
            ScrollView {
                VStack(spacing: 24) {
                    header
                    scrollObservableView
                    LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                        Section {
                            contentScrollView
                        } header: {
                            VStack(spacing: 24) {
                                PokitDivider().padding(.horizontal, -20)
                                filterHeader
                            }
                            .padding(.bottom, 16)
                            .background(.white)
                        }
                    }
                }
            }
            .onPreferenceChange(ScrollOffsetKey.self) {
                if $0 != targetOffset {
                    currentOffset = $0
                }
            }
            .onChange(of: currentOffset, perform: { newOffSet in
                if newOffSet != targetOffset && newOffSet + targetOffset < 10 {
                    isSticky = true
                } else {
                    isSticky = false
                }
            })
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .pokitNavigationBar { navigationBar }
            .overlay(
                if: store.isContentsNotEmpty,
                alignment: .bottomTrailing
            ) {
                Button(action: { send(.링크_추가_버튼_눌렀을때) }) {
                    Image(.icon(.plus))
                        .resizable()
                        .frame(width: 36, height: 36)
                        .padding(12)
                        .foregroundStyle(.pokit(.icon(.inverseWh)))
                        .background {
                            RoundedRectangle(cornerRadius: 9999, style: .continuous)
                                .fill(.pokit(.bg(.brand)))
                        }
                        .frame(width: 60, height: 60)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 39)
            }
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
        PokitHeader(title: isSticky ? store.category.categoryName : "") {
            PokitHeaderItems(placement: .leading) {
                PokitToolbarButton(
                    .icon(.arrowLeft),
                    action: { send(.dismiss) }
                )
            }
            if !store.isFavoriteCategory {
                PokitHeaderItems(placement: .trailing) {
                    PokitToolbarButton(
                        .icon(.kebab),
                        action: { send(.카테고리_케밥_버튼_눌렀을때) }
                    )
                }
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
            if !store.isFavoriteCategory {
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
                    if store.category.keywordType != .default {
                        Text("#\(store.category.keywordType.title)")
                            .foregroundStyle(textColor)
                            .pokitFont(.b2(.m))
                            .padding(.leading, 4.5)
                    }
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
    }
    
    @ViewBuilder
    var filterHeader: some View {
        let isFavoriteCategory = store.isFavoriteCategory
        let favoriteContentsCount = store.contents.filter { $0.content.isFavorite ?? false }.count
        if store.isContentsNotEmpty {
            HStack(spacing: isFavoriteCategory ? 2 : 8) {
                if isFavoriteCategory {
                    Image(.icon(.link))
                        .resizable()
                        .frame(width: 16, height: 16)
                        .foregroundStyle(.pokit(.icon(.secondary)))
                    Text("\(favoriteContentsCount)개")
                        .foregroundStyle(.pokit(.text(.tertiary)))
                        .pokitFont(.b2(.m))
                } else {
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
                }
                
                Spacer()
                PokitIconLTextLink(
                    store.sortType.title,
                    icon: .icon(.align),
                    action: { send(.정렬_버튼_눌렀을때) }
                )
                .contentTransition(.numericText())
            }
        }
    }
    
    var contentScrollView: some View {
        Group {
            if !store.isLoading {
                if !store.isContentsNotEmpty {
                    VStack {
                        PokitCaution(
                            type: .포킷상세_링크없음,
                            action: { send(.링크_추가_버튼_눌렀을때) }
                        )
                        
                        Spacer()
                    }
                } else {
                    LazyVStack(spacing: 0) {
                        ForEach(
                            Array(store.scope(state: \.contents, action: \.contents))
                        ) { store in
                            let isFirst = store.state.id == self.store.contents.first?.id
                            let isLast = store.state.id == self.store.contents.last?.id
                            
                            if !self.store.isFavoriteCategory {
                                ContentCardView(
                                    store: store,
                                    type: .linkList,
                                    isFirst: isFirst,
                                    isLast: isLast
                                )
                            } else {
                                if store.content.isFavorite == true {
                                    ContentCardView(
                                        store: store,
                                        type: .linkList,
                                        isFirst: isFirst,
                                        isLast: isLast
                                    )
                                }
                            }
                        }
                        
                        if store.hasNext {
                            PokitLoading()
                                .task { await send(.pagenation).finish() }
                        }
                        
                        Spacer()
                    }
                    .padding(.bottom, 36)
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
    private var scrollObservableView: some View {
        GeometryReader { proxy in
            let offsetY = proxy.frame(in: .global).origin.y
            Color.clear
                .preference(
                    key: ScrollOffsetKey.self,
                    value: offsetY
                )
                .onAppear { targetOffset = offsetY }
        }
        .frame(height: 0)
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
