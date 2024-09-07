//
//  SelectFieldFeature.swift
//  Feature
//
//  Created by 김도형 on 7/5/24.

import ComposableArchitecture
import Domain
import CoreKit
import Util

@Reducer
public struct SelectFieldFeature {
    /// - Dependency
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.userClient) var userClient
    /// - State
    @ObservableState
    public struct State: Equatable {
        public init(nickname: String) {
            self.domain = .init(nickname: nickname)
        }
        
        var fields: [String] = []
        
        fileprivate var domain: SelectField
        
        var selectedFields: Set<String> {
            get { domain.interest }
            set { domain.interest = newValue }
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
        public enum View: Equatable {
            case onAppear
            case nextButtonTapped
            case backButtonTapped
            case fieldChipTapped(String)
        }
        public enum InnerAction: Equatable {
            case 관심사_목록_조회_결과(interests: [InterestResponse])
        }
        public enum AsyncAction: Equatable { case doNothing }
        public enum ScopeAction: Equatable { case doNothing }
        public enum DelegateAction: Equatable {
            case pushSignUpDoneView(interests: [String])
        }
    }
    /// initiallizer
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
        Reduce(self.core)
    }
}
//MARK: - FeatureAction Effect
private extension SelectFieldFeature {
    /// - View Effect
    func handleViewAction(_ action: Action.ViewAction, state: inout State) -> Effect<Action> {
        switch action {
        case .onAppear:
            return .run { send in
                let response = try await userClient.관심사_목록_조회()
                await send(.inner(.관심사_목록_조회_결과(interests: response)))
            }
        case .nextButtonTapped:
            let interests = Array(state.selectedFields)
            return .send(.delegate(.pushSignUpDoneView(interests: interests)))
        case .backButtonTapped:
            return .run { _ in await self.dismiss() }
        case .fieldChipTapped(let field):
            let result = state.selectedFields.remove(field)
            guard result == nil else { return .none }
            /// - 해당 분야가 `selectedFields`에 없어 삭제를 하지 못한 경우
            state.selectedFields.insert(field)
            return .none
        }
    }
    /// - Inner Effect
    func handleInnerAction(_ action: Action.InnerAction, state: inout State) -> Effect<Action> {
        switch action {
        case let .관심사_목록_조회_결과(interests):
            state.fields = interests.map { $0.description }
            return .none
        }
    }
    /// - Async Effect
    func handleAsyncAction(_ action: Action.AsyncAction, state: inout State) -> Effect<Action> {
        return .none
    }
    /// - Scope Effect
    func handleScopeAction(_ action: Action.ScopeAction, state: inout State) -> Effect<Action> {
        return .none
    }
    /// - Delegate Effect
    func handleDelegateAction(_ action: Action.DelegateAction, state: inout State) -> Effect<Action> {
        return .none
    }
}
