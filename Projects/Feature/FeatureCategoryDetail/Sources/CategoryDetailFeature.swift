//
//  CategoryDetailFeature.swift
//  Feature
//
//  Created by 김민호 on 7/17/24.

import ComposableArchitecture
import DSKit
import Util

@Reducer
public struct CategoryDetailFeature {
    /// - Dependency
    @Dependency(\.dismiss) var dismiss
    /// - State
    @ObservableState
    public struct State: Equatable {
        var mock: IdentifiedArrayOf<DetailItemMock> = []
        var kebobSelectedType: PokitDeleteBottomSheet.SheetType?
        var selectedLinkItem: DetailItemMock?
        /// sheet Presented
        var isCategorySheetPresented: Bool = false
        var isCategorySelectSheetPresented: Bool = false
        var isPokitDeleteSheetPresented: Bool = false
        var isFilterSheetPresented: Bool = false
        
        public init(mock: [DetailItemMock]) {
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
            /// - Button Tapped
            case categoryKebobButtonTapped(PokitDeleteBottomSheet.SheetType, selectedItem: DetailItemMock?)
            case categorySelectButtonTapped
            case filterButtonTapped
            case dismiss
        }
        
        public enum InnerAction: Equatable {
            case pokitCategorySheetPresented(Bool)
            case pokitDeleteSheetPresented(Bool)
        }
        
        public enum AsyncAction: Equatable { case doNothing }
        
        public enum ScopeAction: Equatable {
            case categoryBottomSheet(PokitBottomSheet.Delegate)
            case categoryDeleteBottomSheet(PokitDeleteBottomSheet.Delegate)
            case filterBottomSheet(CategoryFilterSheet.Delegate)
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
private extension CategoryDetailFeature {
    /// - View Effect
    func handleViewAction(_ action: Action.View, state: inout State) -> Effect<Action> {
        switch action {
        case .binding:
            return .none
            
        case let .categoryKebobButtonTapped(selectedType, selectedItem):
            state.kebobSelectedType = selectedType
            state.selectedLinkItem = selectedItem
            return .run { send in await send(.inner(.pokitCategorySheetPresented(true))) }
        
        case .categorySelectButtonTapped:
            return .none
            
        case .filterButtonTapped:
            state.isFilterSheetPresented.toggle()
            return .none
            
        case .dismiss:
            return .run { _ in await dismiss() }
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
        }
    }
    
    /// - Async Effect
    func handleAsyncAction(_ action: Action.AsyncAction, state: inout State) -> Effect<Action> {
        return .none
    }
    
    /// - Scope Effect
    func handleScopeAction(_ action: Action.ScopeAction, state: inout State) -> Effect<Action> {
        switch action {
        /// - 카테고리에 대한 `공유` / `수정` / `삭제` Delegate
        case .categoryBottomSheet(let delegateAction):
            switch delegateAction {
            case .shareCellButtonTapped:
                return .none
                
            case .editCellButtonTapped:
                return .none
                
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
                    guard let selectedItem = state.selectedLinkItem else {
                    /// 🚨 Error Case [1]: 링크 타입의 항목을 삭제하려는데 선택한 `링크항목`이 없을 때
                        state.isPokitDeleteSheetPresented = false
                        return .none
                    }
                    state.mock.remove(id: selectedItem.id)
                    state.isPokitDeleteSheetPresented = false
                    state.kebobSelectedType = nil
                    return .none
                    
                case .포킷삭제:
                    state.isPokitDeleteSheetPresented = false
                    state.kebobSelectedType = nil
                    return .none
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
                return .none
            }
        }
    }
    
    /// - Delegate Effect
    func handleDelegateAction(_ action: Action.DelegateAction, state: inout State) -> Effect<Action> {
        return .none
    }
}
