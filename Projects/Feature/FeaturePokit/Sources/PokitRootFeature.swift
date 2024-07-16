//
//  PokitRootFeature.swift
//  Feature
//
//  Created by 김민호 on 7/16/24.

import ComposableArchitecture
import DSKit
import Util

@Reducer
public struct PokitRootFeature {
    /// - Dependency

    /// - State
    @ObservableState
    public struct State: Equatable {
        var folderType: PokitRootFilterType = .folder(.포킷)
        var sortType: PokitRootFilterType = .sort(.최신순)
        var mock: IdentifiedArrayOf<PokitRootCardMock> = []
        var selectedKebobItem: PokitRootCardMock?
        var isKebobSheetPresented: Bool = false
        var isPokitDeleteSheetPresented: Bool = false
        
        public init(mock: [PokitRootCardMock]) {
            mock.forEach { self.mock.append($0) }
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
            /// - Navigaiton Bar
            case searchButtonTapped
            case alertButtonTapped
            case settingButtonTapped
            /// - Filter
            case filterButtonTapped(PokitRootFilterType.Folder)
            case sortButtonTapped
            /// - Kebob
            case kebobButtonTapped(PokitRootCardMock)

        }
        
        public enum InnerAction: Equatable { case doNothing }
        
        public enum AsyncAction: Equatable { case doNothing }
        
        public enum ScopeAction: Equatable {
            case bottomSheet(PokitBottomSheet.Delegate)
            case deleteBottomSheet(PokitDeleteBottomSheet.Delegate)
        }
        
        public enum DelegateAction: Equatable { case doNothing }
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
            return .none
        case .alertButtonTapped:
            return .none
        case .settingButtonTapped:
            return .none
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
                state.mock.sort { $0.categoryType < $1.categoryType }
            case .sort(.최신순):
                state.mock.sort { $0.createAt < $1.createAt }
            default: return .none
            }
            
            return .none
        case .kebobButtonTapped(let selectedItem):
            state.selectedKebobItem = selectedItem
            state.isKebobSheetPresented.toggle()
            return .none
        }
    }
    
    /// - Inner Effect
    func handleInnerAction(_ action: Action.InnerAction, state: inout State) -> Effect<Action> {
        return .none
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
            guard let selectedItem = state.selectedKebobItem else { return .none }
            return .none
            
        case .bottomSheet(.editCellButtonTapped):
            /// Todo: 수정하기
            guard let selectedItem = state.selectedKebobItem else { return .none }
            return .none
            
        case .bottomSheet(.deleteCellButtonTapped):
            state.isKebobSheetPresented = false
            state.isPokitDeleteSheetPresented = true
            return .none
            
        /// - Pokit Delete BottomSheet Delegate
        case .deleteBottomSheet(.cancelButtonTapped):
            state.isPokitDeleteSheetPresented = false
            return .none
        case .deleteBottomSheet(.deleteButtonTapped):
            /// Todo: 삭제하기
            guard let selectedItem = state.selectedKebobItem else { return .none }
            state.mock.remove(id: selectedItem.id)
            state.isPokitDeleteSheetPresented = false
            return .none
        default: return .none
        }
    }
    
    /// - Delegate Effect
    func handleDelegateAction(_ action: Action.DelegateAction, state: inout State) -> Effect<Action> {
        return .none
    }
}
