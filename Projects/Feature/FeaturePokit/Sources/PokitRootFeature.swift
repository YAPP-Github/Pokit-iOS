//
//  PokitRootFeature.swift
//  Feature
//
//  Created by 김민호 on 7/16/24.

import ComposableArchitecture
import Domain
import CoreKit
import DSKit
import Util

/// `unclassified`: 미분류 키워드

@Reducer
public struct PokitRootFeature {
    /// - Dependency
    @Dependency(\.categoryClient)
    private var categoryClient
    @Dependency(\.contentClient)
    private var contentClient
    /// - State
    @ObservableState
    public struct State: Equatable {
        var folderType: PokitRootFilterType = .folder(.포킷)
        var sortType: PokitRootFilterType = .sort(.최신순)
        
        fileprivate var domain = Pokit()
        var categories: IdentifiedArrayOf<BaseCategoryItem> {
            var identifiedArray = IdentifiedArrayOf<BaseCategoryItem>()
            domain.categoryList.data.forEach { category in
                identifiedArray.append(category)
            }
            return identifiedArray
        }
        var unclassifiedContents: IdentifiedArrayOf<BaseContentItem>? {
            guard let unclassifiedContentList = domain.unclassifiedContentList.data else {
                return nil
            }
            var identifiedArray = IdentifiedArrayOf<BaseContentItem>()
            unclassifiedContentList.forEach { content in
                identifiedArray.append(content)
            }
            return identifiedArray
        }
        
        var selectedKebobItem: BaseCategoryItem?
        var selectedUnclassifiedItem: BaseContentItem?
        
        var isKebobSheetPresented: Bool = false
        var isPokitDeleteSheetPresented: Bool = false
        /// 목록조회 시 호출용
        var listResponse = BasePageableRequest(page: 0, size: 10, sort: ["desc"])
        
        public init() { }
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
            /// - Navigaiton Bar
            case searchButtonTapped
            case alertButtonTapped
            case settingButtonTapped
            /// - Filter
            case filterButtonTapped(PokitRootFilterType.Folder)
            case sortButtonTapped
            /// - Kebob
            case kebobButtonTapped(BaseCategoryItem)
            case unclassifiedKebobButtonTapped(BaseContentItem)
            
            case categoryTapped(BaseCategoryItem)
            case contentItemTapped(BaseContentItem)
            
            case pokitRootViewOnAppeared

        }
        
        public enum InnerAction: Equatable {
            case pokitCategorySheetPresented(Bool)
            case pokitDeleteSheetPresented(Bool)
            case sort
            case onAppearResult(classified: BaseCategoryListInquiry)
            case 목록조회_갱신용
            case 미분류_카테고리_컨텐츠_갱신(contentList: BaseContentListInquiry)
        }
        
        public enum AsyncAction: Equatable {
            case 포킷삭제(categoryId: Int)
            case 미분류_카테고리_컨텐츠_조회
        }
        
        public enum ScopeAction: Equatable {
            case bottomSheet(PokitBottomSheet.Delegate)
            case deleteBottomSheet(PokitDeleteBottomSheet.Delegate)
        }
        
        public enum DelegateAction: Equatable {
            case searchButtonTapped
            case alertButtonTapped
            case settingButtonTapped
            
            case categoryTapped(BaseCategoryItem)
            case 수정하기(BaseCategoryItem)
            case 링크수정하기(id: Int)
            /// 링크상세로 이동
            case contentDetailTapped(BaseContentItem)
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
private extension PokitRootFeature {
    /// - View Effect
    func handleViewAction(_ action: Action.View, state: inout State) -> Effect<Action> {
        switch action {
        /// - Binding Action
        case .binding:
            return .none
        /// - Navigation Bar Tapped Action
        case .searchButtonTapped:
            return .run { send in await send(.delegate(.searchButtonTapped)) }
        case .alertButtonTapped:
            return .run { send in await send(.delegate(.alertButtonTapped)) }
        case .settingButtonTapped:
            return .run { send in await send(.delegate(.settingButtonTapped)) }
        /// - Filter Action
            /// 포킷 / 미분류 버튼 눌렀을 때
        case .filterButtonTapped(let selectedFolderType):
            state.folderType = .folder(selectedFolderType)
            switch selectedFolderType {
            case .미분류:
                return .send(.async(.미분류_카테고리_컨텐츠_조회))
            case .포킷:
                return .none
            }
            /// 최신순 / 이름순 버튼 눌렀을 때
        case .sortButtonTapped:
            state.sortType = .sort(state.sortType == .sort(.이름순) ? .최신순 : .이름순)
            return .send(.inner(.sort))
        /// - 케밥버튼 눌렀을 때
            /// 분류된 아이템의 케밥버튼
        case .kebobButtonTapped(let selectedItem):
            state.selectedKebobItem = selectedItem
            return .run { send in await send(.inner(.pokitCategorySheetPresented(true))) }
            /// 미분류 아이템의 케밥버튼
        case .unclassifiedKebobButtonTapped(let selectedItem):
            state.selectedUnclassifiedItem = selectedItem
            return .run { send in await send(.inner(.pokitCategorySheetPresented(true))) }
            
        /// - 카테고리 항목을 눌렀을 때
        case .categoryTapped(let category):
            return .run { send in await send(.delegate(.categoryTapped(category))) }
        
        /// - 링크 아이템을 눌렀을 때
        case .contentItemTapped(let selectedItem):
            return .run { send in await send(.delegate(.contentDetailTapped(selectedItem))) }
        case .pokitRootViewOnAppeared:
            return .run { [domain = state.domain.categoryList,
                           sortType = state.sortType] send in
                if domain.hasNext {
                    let sort = sortType == .sort(.최신순) ? "desc" : "asc"
                    let request = BasePageableRequest(page: domain.page + 1, size: domain.size, sort: [sort])
                    let classified = try await categoryClient.카테고리_목록_조회(request, true).toDomain()
                    await send(.inner(.onAppearResult(classified: classified)))
                    await send(.inner(.sort))
                } else {
                    await send(.inner(.목록조회_갱신용))
                }
            }
        }
    }
    
    /// - Inner Effect
    func handleInnerAction(_ action: Action.InnerAction, state: inout State) -> Effect<Action> {
        switch action {
        case let .pokitCategorySheetPresented(presented):
            state.isKebobSheetPresented = presented
            return .none
        case let .pokitDeleteSheetPresented(presented):
            state.isPokitDeleteSheetPresented = presented
            return .none
        case let .onAppearResult(classified):
            state.domain.categoryList = classified
            return .none
        case .sort:
            switch state.sortType {
            case .sort(.이름순):
                /// `포킷`의 이름순 정렬일 때
                state.folderType == .folder(.포킷)
                ? state.domain.categoryList.data.sort { $0.categoryName < $1.categoryName }
                : state.domain.unclassifiedContentList.data?.sort { $0.title < $1.title }
                
            case .sort(.최신순):
                /// `포킷`의 최신순 정렬일 때
                state.folderType == .folder(.포킷)
                // - TODO: 정렬 조회 필요
                ? state.domain.categoryList.sort = [
                    .init(
                        direction: "",
                        nullHandling: "",
                        ascending: true,
                        property: "",
                        ignoreCase: false
                    )
                ]
                : state.domain.unclassifiedContentList.data?.sort { $0.createdAt < $1.createdAt }
            default: return .none
            }
            return .none
        case .목록조회_갱신용:
            return .run { [domain = state.domain.categoryList,
                           sortType = state.sortType] send in
                let sort = sortType == .sort(.최신순) ? "desc" : "asc"
                let request = BasePageableRequest(page: 0, size: domain.size, sort: [sort])
                let classified = try await categoryClient.카테고리_목록_조회(request, true).toDomain()
                await send(.inner(.onAppearResult(classified: classified)))
                await send(.inner(.sort))
            }
        case .미분류_카테고리_컨텐츠_갱신(contentList: let contentList):
            state.domain.unclassifiedContentList = contentList
            return .none
        }
    }
    
    /// - Async Effect
    func handleAsyncAction(_ action: Action.AsyncAction, state: inout State) -> Effect<Action> {
        switch action {
        case let .포킷삭제(categoryId):
            return .run { send in
                try await categoryClient.카테고리_삭제(categoryId)
            }
        case .미분류_카테고리_컨텐츠_조회:
            return .run { [
                contentList = state.domain.unclassifiedContentList,
                sortType = state.sortType
            ] send in
                let sort = sortType == .sort(.최신순) ? "desc" : "asc"
                let request = BasePageableRequest(page: 0, size: contentList.size, sort: [sort])
                let contentList = try await contentClient.미분류_카테고리_컨텐츠_조회(
                    request
                ).toDomain()
                await send(.inner(.미분류_카테고리_컨텐츠_갱신(contentList: contentList)))
            }
        }
    }
    
    /// - Scope Effect
    func handleScopeAction(_ action: Action.ScopeAction, state: inout State) -> Effect<Action> {
        switch action {
        /// - Kebob BottomSheet Delegate
        case .bottomSheet(.shareCellButtonTapped):
            /// Todo: 공유하기
            switch state.folderType {
            case .folder(.미분류):
                guard let selectedItem = state.selectedUnclassifiedItem else {
                    /// 🚨 Error Case [1]: 항목을 공유하려는데 항목이 없을 때
                    return .none
                }
                return .none
            case .folder(.포킷):
                guard let selectedItem = state.selectedKebobItem else {
                    /// 🚨 Error Case [1]: 항목을 공유하려는데 항목이 없을 때
                    return .none
                }
                return .none
                
            default: return .none
            }
            
        case .bottomSheet(.editCellButtonTapped):
            /// Todo: 수정하기
            switch state.folderType {
            case .folder(.미분류):
                guard let selectedItem = state.selectedUnclassifiedItem else {
                    /// 🚨 Error Case [1]: 항목을 수정하려는데 항목이 없을 때
                    return .none
                }
                ///Todo: 링크수정으로 이동
                state.isKebobSheetPresented = false
                return .run { [item = state.selectedUnclassifiedItem] send in
                    guard let item else { return }
                    await send(.delegate(.링크수정하기(id: item.id)))
                }
                
            case .folder(.포킷):
                guard let selectedItem = state.selectedKebobItem else {
                    /// 🚨 Error Case [1]: 항목을 수정하려는데 항목이 없을 때
                    return .none
                }
                /// [1] 케밥을 종료
                state.isKebobSheetPresented = false
                /// [2] 수정하기로 이동
                return .run { [item = state.selectedKebobItem] send in
                    guard let item else { return }
                    await send(.delegate(.수정하기(item)))
                }
            default: return .none
            }
            
        case .bottomSheet(.deleteCellButtonTapped):
            return .run { send in
                await send(.inner(.pokitCategorySheetPresented(false)))
                await send(.inner(.pokitDeleteSheetPresented(true)))
            }
            
        /// - Pokit Delete BottomSheet Delegate
        case .deleteBottomSheet(.cancelButtonTapped):
            state.isPokitDeleteSheetPresented = false
            return .none
            
        case .deleteBottomSheet(.deleteButtonTapped):
            /// Todo: 삭제하기
            switch state.folderType {
            case .folder(.미분류):
                guard let selectedItem = state.selectedUnclassifiedItem else {
                    /// 🚨 Error Case [1]: 항목을 삭제하려는데 항목이 없을 때
                    return .none
                }
                guard let index = state.domain.unclassifiedContentList.data?.firstIndex(of: selectedItem) else {
                    return .none
                }
                state.domain.unclassifiedContentList.data?.remove(at: index)
                state.isPokitDeleteSheetPresented = false
                return .none
                
            case .folder(.포킷):
                guard let selectedItem = state.selectedKebobItem else {
                    /// 🚨 Error Case [1]: 항목을 삭제하려는데 항목이 없을 때
                    return .none
                }
                guard let index = state.domain.categoryList.data.firstIndex(of: selectedItem) else {
                    return .none
                }
                state.domain.categoryList.data.remove(at: index)
                state.isPokitDeleteSheetPresented = false
                
                return .run { send in await send(.async(.포킷삭제(categoryId: selectedItem.id))) }
            default: return .none
            }
        default: return .none
        }
    }
    
    /// - Delegate Effect
    func handleDelegateAction(_ action: Action.DelegateAction, state: inout State) -> Effect<Action> {
        return .none
    }
}
