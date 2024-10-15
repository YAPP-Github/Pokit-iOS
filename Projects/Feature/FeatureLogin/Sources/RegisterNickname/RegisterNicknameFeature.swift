//
//  RegisterNicknameFeature.swift
//  Feature
//
//  Created by 김도형 on 7/5/24.

import ComposableArchitecture
import Domain
import CoreKit
import DSKit
import Util

@Reducer
public struct RegisterNicknameFeature {
    /// - Dependency
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(UserClient.self) var userClient
    /// - State
    @ObservableState
    public struct State: Equatable {
        public init() {}
        
        fileprivate var domain = RegisterNickname()
        var nicknameText: String {
            get { domain.nickname }
            set { domain.nickname = newValue }
        }
        var isDuplicate: Bool {
            get { domain.isDuplicate }
            set { domain.isDuplicate = newValue }
        }
        var buttonActive: Bool = false
        var textfieldState: PokitInputStyle.State = .default
    }
    /// - Action
    public enum Action: FeatureAction, ViewAction {
        case view(View)
        case inner(InnerAction)
        case async(AsyncAction)
        case scope(ScopeAction)
        case delegate(DelegateAction)
        
        public enum View: Equatable, BindableAction {
            /// - Binding
            case binding(BindingAction<State>)
            /// - Button Tapped
            case 다음_버튼_눌렀을때
            case dismiss
        }
        
        public enum InnerAction: Equatable {
            case 닉네임_텍스트_변경되었을때
            case 닉네임_중복_체크_API_반영(Bool)
        }
        
        public enum AsyncAction: Equatable {
            case 닉네임_중복_체크_API
        }
        public enum ScopeAction: Equatable { case 없음 }
        public enum DelegateAction: Equatable {
            case pushSelectFieldView(nickname: String)
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
    public enum CancelID { case response }
    /// - Reducer body
    public var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)
        Reduce(self.core)
    }
}
//MARK: - FeatureAction Effect
private extension RegisterNicknameFeature {
    /// - View Effect
    func handleViewAction(_ action: Action.ViewAction, state: inout State) -> Effect<Action> {
        switch action {
        case .다음_버튼_눌렀을때:
            let nickname = state.nicknameText
            return .send(.delegate(.pushSelectFieldView(nickname: nickname)))
        case .dismiss:
            return .run { _ in await self.dismiss() }
        case .binding(\.nicknameText):
            state.buttonActive = false
            return .send(.inner(.닉네임_텍스트_변경되었을때)).debounce(
                id: CancelID.response,
                for: 0.5,
                scheduler: mainQueue
            )
        case .binding:
            return .none
        }
    }
    /// - Inner Effect
    func handleInnerAction(_ action: Action.InnerAction, state: inout State) -> Effect<Action> {
        switch action {
        case .닉네임_텍스트_변경되었을때:
            /// [1]. 닉네임 텍스트필드가 비어있을 때
            if state.nicknameText.isEmpty {
                state.buttonActive = false
                return .none
            }
            /// [2]. 닉네임이 10자를 넘을 때
            if state.nicknameText.count > 10 {
                state.buttonActive = false
                state.textfieldState = .error(message: "최대 10자까지 입력 가능합니다.")
                return .none
            }
            /// [3]. 닉네임에 특수문자가 포함되어 있을 때
            if !state.nicknameText.isNickNameValid {
                state.buttonActive = false
                state.textfieldState = .error(message: "한글, 영어, 숫자만 입력이 가능합니다.")
                return .none
            } else {
                /// [4]. 정상 케이스일 때
                return .run { send in await send(.async(.닉네임_중복_체크_API)) }
            }

        case let .닉네임_중복_체크_API_반영(isDuplicate):
            if isDuplicate {
                state.textfieldState = .error(message: "중복된 닉네임입니다.")
                state.buttonActive = false
            } else {
                state.textfieldState = .active
                state.buttonActive = true
            }
            return .none
        }
    }
    /// - Async Effect
    func handleAsyncAction(_ action: Action.AsyncAction, state: inout State) -> Effect<Action> {
        switch action {
        case .닉네임_중복_체크_API:
            return .run { [nickName = state.nicknameText] send in
                let result = try await userClient.닉네임_중복_체크(nickName)
                await send(.inner(.닉네임_중복_체크_API_반영(result.isDuplicate)))
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
