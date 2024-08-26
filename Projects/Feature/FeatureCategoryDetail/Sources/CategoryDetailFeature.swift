//
//  CategoryDetailFeature.swift
//  Feature
//
//  Created by 김민호 on 7/17/24.

import Foundation

import ComposableArchitecture
import Domain
import CoreKit
import DSKit
import Util

@Reducer
public struct CategoryDetailFeature {
    /// - Dependency
    @Dependency(\.dismiss)
    private var dismiss
    @Dependency(\.pasteboard)
    private var pasteboard
    @Dependency(\.categoryClient)
    private var categoryClient
    @Dependency(\.contentClient)
    private var contentClient
    @Dependency(\.kakaoShareClient)
    private var kakaoShareClient
    /// - State
    @ObservableState
    public struct State: Equatable {
        /// Domain
        fileprivate var domain: CategoryDetail
        var category: BaseCategoryItem {
            get { domain.category }
        }
        var isUnreadFiltered: Bool {
            get { domain.condition.isUnreadFlitered }
        }
        var isFavoriteFiltered: Bool {
            get { domain.condition.isFavoriteFlitered }
        }
        
        var sortType: SortType = .최신순
        var categories: IdentifiedArrayOf<BaseCategoryItem>? {
            guard let categoryList = domain.categoryListInQuiry.data else {
                return nil
            }
            var identifiedArray = IdentifiedArrayOf<BaseCategoryItem>()
            categoryList.forEach { category in
                identifiedArray.append(category)
            }
            return identifiedArray
        }
        var contents: IdentifiedArrayOf<BaseContentItem>? {
            guard let contentList = domain.contentList.data else {
                return nil
            }
            var identifiedArray = IdentifiedArrayOf<BaseContentItem>()
            contentList.forEach { content in
                identifiedArray.append(content)
            }
            return identifiedArray
        }
        var kebobSelectedType: PokitDeleteBottomSheet.SheetType?
        var selectedContentItem: BaseContentItem?
        /// sheet Presented
        var isCategorySheetPresented: Bool = false
        var isCategorySelectSheetPresented: Bool = false
        var isPokitDeleteSheetPresented: Bool = false
        var isFilterSheetPresented: Bool = false
        /// pagenation
        var hasNext: Bool {
            domain.contentList.hasNext
        }
        
        public init(category: BaseCategoryItem) {
            self.domain = .init(categpry: category)
        }
    }
    
    /// - Action
    public enum Action: FeatureAction, ViewAction {
        case view(View)
        case inner(InnerAction)
        case async(AsyncAction)
        case scope(ScopeAction)
        case delegate(DelegateAction)
        
        @CasePathable
        public enum View: BindableAction, Equatable {
            /// - Binding
            case binding(BindingAction<State>)
            /// - Button Tapped
            case categoryKebobButtonTapped(PokitDeleteBottomSheet.SheetType, selectedItem: BaseContentItem?)
            case categorySelectButtonTapped
            case categorySelected(BaseCategoryItem)
            case filterButtonTapped
            case contentItemTapped(BaseContentItem)
            case dismiss
            case onAppear
            case pagenation
        }
        
        public enum InnerAction: Equatable {
            case pokitCategorySheetPresented(Bool)
            case pokitCategorySelectSheetPresented(Bool)
            case pokitDeleteSheetPresented(Bool)
            case 카테고리_목록_조회_결과(BaseCategoryListInquiry)
            case 카테고리_내_컨텐츠_목록_갱신(BaseContentListInquiry)
            case 컨텐츠_삭제_반영(id: Int)
            case pagenation_네트워크_결과(BaseContentListInquiry)
            case pagenation_초기화
        }
        
        public enum AsyncAction: Equatable {
            case 카테고리_내_컨텐츠_목록_조회
            case 컨텐츠_삭제(id: Int)
            case pagenation_네트워크
        }
        
        public enum ScopeAction: Equatable {
            case categoryBottomSheet(PokitBottomSheet.Delegate)
            case categoryDeleteBottomSheet(PokitDeleteBottomSheet.Delegate)
            case filterBottomSheet(CategoryFilterSheet.Delegate)
        }
        
        public enum DelegateAction: Equatable {
            case contentItemTapped(BaseContentItem)
            case linkCopyDetected(URL?)
            case 링크수정(contentId: Int)
            case 포킷삭제
            case 포킷수정(BaseCategoryItem)
            case 포킷공유
            case 카테고리_내_컨텐츠_목록_조회
        }
    }
    
    /// - Initiallizer
    public init() {}

    /// - Reducer Core
    private func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
            /// - View
        case .view(let viewAction):
            return handleViewAction(viewAction, state: &state)
            
            /// - Inner
        case .inner(let innerAction):
            return handleInnerAction(innerAction, state: &state)
            
            /// - Async
        case .async(let asyncAction):
            return handleAsyncAction(asyncAction, state: &state)
            
            /// - Scope
        case .scope(let scopeAction):
            return handleScopeAction(scopeAction, state: &state)
            
            /// - Delegate
        case .delegate(let delegateAction):
            return handleDelegateAction(delegateAction, state: &state)
        }
    }
    
    /// - Reducer body
    public var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)
        Reduce(self.core)
    }
}
//MARK: - FeatureAction Effect
private extension CategoryDetailFeature {
    /// - View Effect
    func handleViewAction(_ action: Action.View, state: inout State) -> Effect<Action> {
        switch action {
        case .binding:
            return .none
            
        case let .categoryKebobButtonTapped(selectedType, selectedItem):
            state.kebobSelectedType = selectedType
            state.selectedContentItem = selectedItem
            return .run { send in await send(.inner(.pokitCategorySheetPresented(true))) }
        
        case .categorySelectButtonTapped:
            return .send(.inner(.pokitCategorySelectSheetPresented(true)))
            
        case .categorySelected(let item):
            state.domain.contentList.data = nil
            state.domain.category = item
            return .run { send in
                await send(.async(.카테고리_내_컨텐츠_목록_조회))
                await send(.inner(.pokitCategorySelectSheetPresented(false)))
            }
            
        case .filterButtonTapped:
            state.isFilterSheetPresented.toggle()
            return .none
            
        case .contentItemTapped(let selectedItem):
            return .run { send in await send(.delegate(.contentItemTapped(selectedItem))) }
            
        case .dismiss:
            return .run { _ in await dismiss() }
            
        case .onAppear:
            return .run { send in
                let request = BasePageableRequest(page: 0, size: 30, sort: ["createdAt,desc"])
                let response = try await categoryClient.카테고리_목록_조회(request, true).toDomain()
                await send(.async(.카테고리_내_컨텐츠_목록_조회))
                await send(.inner(.카테고리_목록_조회_결과(response)))
                
                for await _ in self.pasteboard.changes() {
                    let url = try await pasteboard.probableWebURL()
                    await send(.delegate(.linkCopyDetected(url)), animation: .pokitSpring)
                }
            }
        case .pagenation:
            return .run { send in await send(.async(.pagenation_네트워크)) }
        }
    }
    
    /// - Inner Effect
    func handleInnerAction(_ action: Action.InnerAction, state: inout State) -> Effect<Action> {
        switch action {
        case let .pokitCategorySheetPresented(presented):
            state.isCategorySheetPresented = presented
            return .none
        
        case let .pokitDeleteSheetPresented(presented):
            state.isPokitDeleteSheetPresented = presented
            return .none
            
        case let .pokitCategorySelectSheetPresented(presented):
            state.isCategorySelectSheetPresented = presented
            return .none
            
        case let .카테고리_목록_조회_결과(response):
            state.domain.categoryListInQuiry = response
            guard let first = response.data?.first(where: { item in
                item.id == state.domain.category.id
            }) else { return .none }
            state.domain.category = first
            return .none
        case .카테고리_내_컨텐츠_목록_갱신(let contentList):
            state.domain.contentList = contentList
            return .none
        case .컨텐츠_삭제_반영(id: let id):
            state.domain.contentList.data?.removeAll { $0.id == id }
            state.domain.category.contentCount -= 1
            state.selectedContentItem = nil
            state.isPokitDeleteSheetPresented = false
            state.kebobSelectedType = nil
            return .none
        case .pagenation_네트워크_결과(let contentList):
            state.domain.contentList = contentList
            return .none
        case .pagenation_초기화:
            state.domain.pageable.page = 0
            state.domain.contentList.data = nil
            return .send(.async(.카테고리_내_컨텐츠_목록_조회))
        }
    }
    
    /// - Async Effect
    func handleAsyncAction(_ action: Action.AsyncAction, state: inout State) -> Effect<Action> {
        switch action {
        case .카테고리_내_컨텐츠_목록_조회:
            return .run { [
                id = state.domain.category.id,
                pageable = state.domain.pageable,
                condition = state.domain.condition
            ] send in
                let contentList = try await contentClient.카테고리_내_컨텐츠_목록_조회(
                    "\(id)",
                    BasePageableRequest(
                        page: pageable.page,
                        size: pageable.size,
                        sort: pageable.sort
                    ),
                    BaseConditionRequest(
                        categoryIds: condition.categoryIds,
                        isRead: condition.isUnreadFlitered,
                        favorites: condition.isFavoriteFlitered
                    )
                ).toDomain()
                await send(.inner(.카테고리_내_컨텐츠_목록_갱신(contentList)), animation: .pokitDissolve)
            }
        case .컨텐츠_삭제(id: let id):
            return .run { [id] send in
                let _ = try await contentClient.컨텐츠_삭제("\(id)")
                await send(.inner(.컨텐츠_삭제_반영(id: id)), animation: .pokitSpring)
            }
        case .pagenation_네트워크:
            state.domain.pageable.page += 1
            return .send(.async(.카테고리_내_컨텐츠_목록_조회))
        }
    }
    
    /// - Scope Effect
    func handleScopeAction(_ action: Action.ScopeAction, state: inout State) -> Effect<Action> {
        switch action {
        /// - 카테고리에 대한 `공유` / `수정` / `삭제` Delegate
        case .categoryBottomSheet(let delegateAction):
            switch delegateAction {
            case .shareCellButtonTapped:
                kakaoShareClient.카테고리_카카오톡_공유(
                    CategoryKaKaoShareModel(
                        categoryName: state.domain.category.categoryName,
                        categoryId: state.domain.category.id,
                        imageURL: state.domain.category.categoryImage.imageURL
                    )
                )
                state.isCategorySheetPresented = false
                return .none
                
            case .editCellButtonTapped:
                return .run { [
                    content = state.selectedContentItem,
                    type = state.kebobSelectedType,
                    category = state.category
                ] send in
                    guard let type else { return }
                    switch type {
                    case .링크삭제:
                        guard let content else { return }
                        await send(.inner(.pokitCategorySheetPresented(false)))
                        await send(.delegate(.링크수정(contentId: content.id)))
                    case .포킷삭제:
                        await send(.inner(.pokitCategorySheetPresented(false)))
                        await send(.delegate(.포킷수정(category)))
                    }
                }
                
            case .deleteCellButtonTapped:
                return .run { send in
                    await send(.inner(.pokitCategorySheetPresented(false)))
                    await send(.inner(.pokitDeleteSheetPresented(true)))
                }
                
            default: return .none
            }
        /// - 카테고리의 `삭제`를 눌렀을 때 Sheet Delegate
        case .categoryDeleteBottomSheet(let delegateAction):
            switch delegateAction {
            case .cancelButtonTapped:
                return .run { send in await send(.inner(.pokitDeleteSheetPresented(false))) }
                
            case .deleteButtonTapped:
                guard let selectedType = state.kebobSelectedType else {
                    /// 🚨 Error Case [1]: 해당 타입의 항목을 삭제하려는데 선택한 `타입`이 없을 때
                    state.isPokitDeleteSheetPresented = false
                    return .none
                }
                switch selectedType {
                case .링크삭제:
                    guard let selectedItem = state.selectedContentItem else {
                    /// 🚨 Error Case [1]: 링크 타입의 항목을 삭제하려는데 선택한 `링크항목`이 없을 때
                        state.isPokitDeleteSheetPresented = false
                        return .none
                    }
                    return .send(.async(.컨텐츠_삭제(id: selectedItem.id)))
                case .포킷삭제:
                    state.isPokitDeleteSheetPresented = false
                    state.kebobSelectedType = nil
                    return .run { [categoryId = state.domain.category.id] send in
                        await send(.inner(.pokitDeleteSheetPresented(false)))
                        await send(.delegate(.포킷삭제))
                        try await categoryClient.카테고리_삭제(categoryId)
                    }
                }
            }
        /// - 필터 버튼을 눌렀을 때
        case .filterBottomSheet(let delegateAction):
            switch delegateAction {
            case .dismissButtonTapped:
                state.isFilterSheetPresented.toggle()
                return .none
            case let .okButtonTapped(type, bookMarkSelected, unReadSelected):
                state.isFilterSheetPresented.toggle()
                state.domain.pageable.sort = [
                    type == .최신순 ? "createdAt,desc" : "createdAt,asc"
                ]
                state.sortType = type
                state.domain.condition.isFavoriteFlitered = bookMarkSelected
                state.domain.condition.isUnreadFlitered = unReadSelected
                return .send(.inner(.pagenation_초기화), animation: .pokitDissolve)
            }
        }
    }
    
    /// - Delegate Effect
    func handleDelegateAction(_ action: Action.DelegateAction, state: inout State) -> Effect<Action> {
        switch action {
        case .카테고리_내_컨텐츠_목록_조회:
            return .send(.async(.카테고리_내_컨텐츠_목록_조회))
        default:
            return .none
        }
    }
}
