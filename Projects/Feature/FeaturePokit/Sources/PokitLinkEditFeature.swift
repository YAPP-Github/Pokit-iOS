//
//  PokitLinkEditFeature.swift
//  Feature
//
//  Created by 김민호 on 12/24/24.

import ComposableArchitecture
import Domain
import Util

@Reducer
public struct PokitLinkEditFeature {
    /// - Dependency
    @Dependency(\.dismiss) var dismiss
    /// - State
    @ObservableState
    public struct State: Equatable {
        var item: BaseContentListInquiry
        var list = IdentifiedArrayOf<BaseContentItem>()
        var selectedItems = IdentifiedArrayOf<BaseContentItem>()
        var isPresented: Bool = false
        
        public init(linkList: BaseContentListInquiry) {
            self.item = linkList
            if let data = self.item.data {
                data.forEach { list.append($0) }
            }
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
            case binding(BindingAction<State>)
            case dismiss
            
            case 체크박스_선택했을때(BaseContentItem)
            case 카테고리_선택했을때(BaseCategoryItem)
        }
        
        public enum InnerAction: Equatable { case 없음 }
        
        public enum AsyncAction: Equatable { case 없음 }
        
        public enum ScopeAction: Equatable {
            case floatButtonAction(PokitLinkEditFloatView.Delegate)
        }
        
        public enum DelegateAction: Equatable { case 없음 }
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
private extension PokitLinkEditFeature {
    /// - View Effect
    func handleViewAction(_ action: Action.View, state: inout State) -> Effect<Action> {
        switch action {
        case .binding:
            return .none
            
        case .dismiss:
            return .run { _ in await dismiss() }
            
        case let .체크박스_선택했을때(item):
            /// 이미 체크되어 있다면 해제
            if state.selectedItems.contains(item) {
                state.selectedItems.remove(id: item.id)
            } else {
                state.selectedItems.append(item)
            }
            return .none
            
        case let .카테고리_선택했을때(pokit):
            //TODO: 포킷이동 네트워크 구현
            state.isPresented = false
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
        case let .floatButtonAction(delegate):
            switch delegate {
            case .링크삭제_버튼_눌렀을때:
                return .none
                
            case .전체선택_버튼_눌렀을때:
                state.selectedItems = state.list
                return .none
                
            case .전체해제_버튼_눌렀을때:
                state.selectedItems.removeAll()
                return .none
                
            case .포킷이동_버튼_눌렀을때:
                state.isPresented = true
                return .none
            }
        }
    }
    
    /// - Delegate Effect
    func handleDelegateAction(_ action: Action.DelegateAction, state: inout State) -> Effect<Action> {
        return .none
    }
}