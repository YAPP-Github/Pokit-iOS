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

    /// - State
    @ObservableState
    public struct State: Equatable {
        var folderType: PokitRootFilterType = .folder(.포킷)
        var sortType: PokitRootFilterType = .sort(.최신순)
        
        fileprivate var domain = Pokit()
        var categories: IdentifiedArrayOf<BaseCategory> {
            var identifiedArray = IdentifiedArrayOf<BaseCategory>()
            domain.categoryList.data.forEach { category in
                identifiedArray.append(category)
            }
            return identifiedArray
        }
        var unclassifiedContents: IdentifiedArrayOf<BaseContent> {
            var identifiedArray = IdentifiedArrayOf<BaseContent>()
            domain.unclassifiedContentList.data.forEach { content in
                identifiedArray.append(content)
            }
            return identifiedArray
        }
        
        var selectedKebobItem: BaseCategory?
        var selectedUnclassifiedItem: BaseContent?
        
        var isKebobSheetPresented: Bool = false
        var isPokitDeleteSheetPresented: Bool = false
        
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
            case kebobButtonTapped(BaseCategory)
            case unclassifiedKebobButtonTapped(BaseContent)
            
            case categoryTapped(BaseCategory)
            case linkItemTapped(BaseContent)
            
            case pokitRootViewOnAppeared

        }
        
        public enum InnerAction: Equatable {
            case pokitCategorySheetPresented(Bool)
            case pokitDeleteSheetPresented(Bool)
        }
        
        public enum AsyncAction: Equatable { case doNothing }
        
        public enum ScopeAction: Equatable {
            case bottomSheet(PokitBottomSheet.Delegate)
            case deleteBottomSheet(PokitDeleteBottomSheet.Delegate)
        }
        
        public enum DelegateAction: Equatable {
            case searchButtonTapped
            case alertButtonTapped
            case settingButtonTapped
            
            case categoryTapped(BaseCategory)
            case 수정하기(BaseCategory)
            case 링크수정하기(BaseContent)
            /// 링크상세로 이동
            case linkDetailTapped(BaseContent)
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
            return .none
            /// 최신순 / 이름순 버튼 눌렀을 때
        case .sortButtonTapped:
            state.sortType = .sort(state.sortType == .sort(.이름순) ? .최신순 : .이름순)
            
            switch state.sortType {
            case .sort(.이름순):
                /// `포킷`의 이름순 정렬일 때
                state.folderType == .folder(.포킷)
                ? state.domain.categoryList.data.sort { $0.categoryName < $1.categoryName }
                : state.domain.unclassifiedContentList.data.sort { $0.title < $1.title }
                
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
                : state.domain.unclassifiedContentList.data.sort { $0.createdAt < $1.createdAt }
            default: return .none
            }
            
            return .none
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
        case .linkItemTapped(let selectedItem):
            return .run { send in await send(.delegate(.linkDetailTapped(selectedItem))) }
        case .pokitRootViewOnAppeared:
            // - MARK: 목업 데이터 조회
            state.domain.categoryList = CategoryListInquiryResponse.mock.toDomain()
            state.domain.unclassifiedContentList = ContentListInquiryResponse.mock.toDomain()
            return .none
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
        }
    }
    
    /// - Async Effect
    func handleAsyncAction(_ action: Action.AsyncAction, state: inout State) -> Effect<Action> {
        return .none
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
                    await send(.delegate(.링크수정하기(item)))
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
                guard let index = state.domain.unclassifiedContentList.data.firstIndex(of: selectedItem) else {
                    return .none
                }
                state.domain.unclassifiedContentList.data.remove(at: index)
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
                return .none
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
