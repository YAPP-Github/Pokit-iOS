//
//  NickNameSettingFeature.swift
//  Feature
//
//  Created by 김민호 on 7/22/24.

import ComposableArchitecture
import Domain
import CoreKit
import DSKit
import Util

@Reducer
public struct NickNameSettingFeature {
    /// - Dependency
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.userClient) var userClient
    @Dependency(\.mainQueue) var mainQueue
    /// - State
    @ObservableState
    public struct State: Equatable {
        fileprivate var domain = NicknameSetting()
        var text: String {
            get { self.domain.nickname }
            set { self.domain.nickname = newValue }
        }
        
        var textfieldState: PokitInputStyle.State = .default
        var buttonState: PokitButtonStyle.State = .disable
        
        public init() {}
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
            case saveButtonTapped
        }
        
        public enum InnerAction: Equatable {
            case textChanged
            case 닉네임_중복_체크_네트워크_결과(Bool)
        }
        
        public enum AsyncAction: Equatable {
            case 닉네임_중복_체크_네트워크
        }
        
        public enum ScopeAction: Equatable { case doNothing }
        
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
    public enum CancelID { case response }
    /// - Reducer body
    public var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)
        Reduce(self.core)
    }
}
//MARK: - FeatureAction Effect
private extension NickNameSettingFeature {
    /// - View Effect
    func handleViewAction(_ action: Action.View, state: inout State) -> Effect<Action> {
        switch action {
        case .binding(\.text):
            state.buttonState = .disable
            return .run { send in
                await send(.inner(.textChanged))
            }
            .debounce(
                id: CancelID.response,
                for: 3.0, scheduler: mainQueue
            )
        case .binding:
            // - MARK: 목업 데이터 조회
            state.domain.isDuplicate = NicknameCheckResponse.mock.toDomain()
            return .none
            
        case .dismiss:
            return .run { _ in await dismiss() }
            
        case .saveButtonTapped:
            return .run { [nickName = state.text] send in
                let request = NicknameEditRequest(nickname: nickName)
                let _ = try await userClient.닉네임_수정(request)
                await dismiss()
            }
        }
    }
    
    /// - Inner Effect
    func handleInnerAction(_ action: Action.InnerAction, state: inout State) -> Effect<Action> {
        switch action {
        case .textChanged:
            if state.text.isEmpty || state.text.count > 10 {
                state.buttonState = .disable
                return .none
            } else {
                return .run { send in
                    await send(.async(.닉네임_중복_체크_네트워크))
                }
            }
        case let .닉네임_중복_체크_네트워크_결과(isDuplicate):
            if isDuplicate {
                state.textfieldState = .error
                state.buttonState = .disable
            } else {
                state.textfieldState = .active
                state.buttonState = .filled(.primary)
            }
            return .none
        }
    }
    
    /// - Async Effect
    func handleAsyncAction(_ action: Action.AsyncAction, state: inout State) -> Effect<Action> {
        switch action {
        case .닉네임_중복_체크_네트워크:
            return .run { [nickName = state.text] send in
                let result = try await userClient.닉네임_중복_체크(nickName)
                await send(.inner(.닉네임_중복_체크_네트워크_결과(result.isDuplicate)))
            }
        }
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
