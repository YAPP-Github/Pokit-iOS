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
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(UserClient.self) var userClient
    /// - State
    @ObservableState
    public struct State: Equatable {
        fileprivate var domain = NicknameSetting()
        var text: String {
            get { self.domain.nickname }
            set { self.domain.nickname = newValue }
        }
        var user: BaseUser? {
            get { domain.user }
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
            case 저장_버튼_눌렀을때
            case 뷰가_나타났을때
            case 닉네임지우기_버튼_눌렀을때
        }
        
        public enum InnerAction: Equatable {
            case 닉네임_텍스트_변경되었을때
            case 닉네임_중복_확인_API_반영(Bool)
            case 닉네임_조회_API_반영(BaseUser)
        }
        
        public enum AsyncAction: Equatable {
            case 닉네임_중복_확인_API
            case 닉네임_조회_API
        }
        
        public enum ScopeAction: Equatable { case 없음 }
        
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
                await send(.inner(.닉네임_텍스트_변경되었을때))
            }
            .debounce(
                id: CancelID.response,
                for: 0.5,
                scheduler: mainQueue
            )
            
        case .binding:
            return .none
            
        case .dismiss:
            return .run { _ in await dismiss() }
            
        case .저장_버튼_눌렀을때:
            return .run { [nickName = state.text] send in
                let request = NicknameEditRequest(nickname: nickName)
                let _ = try await userClient.닉네임_수정(request)
                await dismiss()
            }
            
        case .뷰가_나타났을때:
            return .send(.async(.닉네임_조회_API))
        case .닉네임지우기_버튼_눌렀을때:
            state.domain.nickname = ""
            return .none
        }
    }
    
    /// - Inner Effect
    func handleInnerAction(_ action: Action.InnerAction, state: inout State) -> Effect<Action> {
        switch action {
        case .닉네임_텍스트_변경되었을때:
            /// [1]. 닉네임 텍스트필드가 비어있을 때
            if state.text.isEmpty {
                state.buttonState = .disable
                return .none
            }
            /// [2]. 닉네임이 10자를 넘을 때
            if state.text.count > 10 {
                state.buttonState = .disable
                state.textfieldState = .error(message: "최대 10자까지 입력 가능합니다.")
                return .none
            }
            /// [3]. 닉네임에 특수문자가 포함되어 있을 때
            if !state.text.isNickNameValid {
                state.buttonState = .disable
                state.textfieldState = .error(message: "한글, 영어, 숫자만 입력이 가능합니다.")
                return .none
            } else {
                /// [4]. 정상 케이스일 때
                return .run { send in await send(.async(.닉네임_중복_확인_API)) }
            }
            
        case let .닉네임_중복_확인_API_반영(isDuplicate):
            state.textfieldState = isDuplicate
            ? .error(message: "중복된 닉네임입니다.")
            : .active
            
            state.buttonState = isDuplicate
            ? .disable
            : .filled(.primary)
            return .none
            
        case let .닉네임_조회_API_반영(user):
            state.domain.user = user
            state.domain.nickname = user.nickname
            return .none
        }
    }
    
    /// - Async Effect
    func handleAsyncAction(_ action: Action.AsyncAction, state: inout State) -> Effect<Action> {
        switch action {
        case .닉네임_중복_확인_API:
            return .run { [nickName = state.text] send in
                let result = try await userClient.닉네임_중복_체크(nickName)
                await send(.inner(.닉네임_중복_확인_API_반영(result.isDuplicate)))
            }
            
        case .닉네임_조회_API:
            return .run { send in
                let user = try await userClient.닉네임_조회().toDomain()
                await send(.inner(.닉네임_조회_API_반영(user)), animation: .easeInOut)
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
