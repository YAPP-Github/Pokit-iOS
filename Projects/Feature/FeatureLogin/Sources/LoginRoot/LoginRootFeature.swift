//
//  SignUpNavigationStackFeature.swift
//  Feature
//
//  Created by 김도형 on 7/7/24.

import ComposableArchitecture
import CoreKit
import Util

@Reducer
public struct LoginRootFeature {
    /// - Dependency
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.socialLogin) var socialLogin
    @Dependency(\.authClient) var authClient
    @Dependency(\.userClient) var userClient
    @Dependency(\.userDefaults) var userDefaults
    @Dependency(\.keychain) var keychain
    /// - State
    @ObservableState
    public struct State {
        var path = StackState<Path.State>()

        var nickName: String?
        var interests: [String]?
        
        public init() {}
    }
    /// - Action
    public enum Action: FeatureAction, ViewAction {
        case view(View)
        case inner(InnerAction)
        case async(AsyncAction)
        case scope(ScopeAction)
        case delegate(DelegateAction)
        case path(StackActionOf<Path>)
        
        @CasePathable
        public enum View: Equatable {
            /// - Button Tapped
            case appleLoginButtonTapped
            case googleLoginButtonTapped
        }
        public enum InnerAction: Equatable {
            case pushAgreeToTermsView
            case pushRegisterNicknameView
            case pushSelectFieldView(nickname: String)
            case pushSignUpDoneView
        }
        public enum AsyncAction: Equatable {
            case 회원가입
        }
        public enum ScopeAction {
            case agreeToTerms(AgreeToTermsFeature.Action.DelegateAction)
            case registerNickname(RegisterNicknameFeature.Action.DelegateAction)
            case selectField(SelectFieldFeature.Action.DelegateAction)
            case signUpDone(SignUpDoneFeature.Action.DelegateAction)
        }
        public enum DelegateAction: Equatable {
            case dismissLoginRootView
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
        case .path(let pathAction):
            return handlePathAction(pathAction, state: &state)
        }
    }
    /// - Reducer body
    public var body: some ReducerOf<Self> {
        Reduce(self.core)
            .forEach(\.path, action: \.path)
    }
}
//MARK: - FeatureAction Effect
private extension LoginRootFeature {
    /// - View Effect
    func handleViewAction(_ action: Action.View, state: inout State) -> Effect<Action> {
        switch action {
        case .appleLoginButtonTapped:
            return .send(.inner(.pushAgreeToTermsView))
            
        case .googleLoginButtonTapped:
            return .run { send in
                let response = try await socialLogin.googleLogin()
                guard let idToken = response.idToken else { return }
                let platform = response.provider.description
                let request = SignInRequest(authPlatform: platform, idToken: idToken)
                let tokenResponse = try await authClient.로그인(request)
                
                /// [1]. UserDefaults에 최근 로그인한 소셜로그인 `타입`저장
                await userDefaults.setString(platform, .authPlatform)
                /// [2]. Keychain에 `access`, `refresh` 저장
                keychain.save(.accessToken, tokenResponse.accessToken)
                keychain.save(.refreshToken, tokenResponse.refreshToken)
                await send(.inner(.pushAgreeToTermsView))
            }
        }
    }
    /// - Inner Effect
    func handleInnerAction(_ action: Action.InnerAction, state: inout State) -> Effect<Action> {
        switch action {
        case .pushAgreeToTermsView:
            state.path.append(.agreeToTerms(.init()))
            return .none
        case .pushRegisterNicknameView:
            state.path.append(.registerNickname(.init()))
            return .none
        case .pushSelectFieldView(let nickname):
            state.path.append(.selecteField(.init(nickname: nickname)))
            return .none
        case .pushSignUpDoneView:
            state.path.append(.signUpDone(.init()))
            return .none
        }
    }
    /// - Async Effect
    func handleAsyncAction(_ action: Action.AsyncAction, state: inout State) -> Effect<Action> {
        switch action {
        case .회원가입:
            return .run { [nickName = state.nickName, interests = state.interests] send in
                guard let nickName else { return }
                guard let interests else { return }
                let signUpRequest = SignupRequest(nickName: nickName, interests: interests)
                let a = try await userClient.회원등록(signUpRequest)
                
                await send(.inner(.pushSignUpDoneView))
            }
        }
    }
    /// - Scope Effect
    func handleScopeAction(_ action: Action.ScopeAction, state: inout State) -> Effect<Action> {
        switch action {
        case .agreeToTerms(let delegate):
            switch delegate {
            case .pushRegisterNicknameView:
                return .send(.inner(.pushRegisterNicknameView))
            }
        case .registerNickname(let delegate):
            switch delegate {
            case .pushSelectFieldView(let nickname):
                state.nickName = nickname
                return .send(.inner(.pushSelectFieldView(nickname: nickname)))
            }
        case .selectField(let delegate):
            switch delegate {
            case let .pushSignUpDoneView(interests):
                state.interests = interests
                return .send(.async(.회원가입))
            }
        case .signUpDone(let delegate):
            switch delegate {
            case .dismissLoginRootView:
                return .send(.delegate(.dismissLoginRootView))
            }
        }
    }
    /// - Delegate Effect
    func handleDelegateAction(_ action: Action.DelegateAction, state: inout State) -> Effect<Action> {
        return .none
    }

    func handlePathAction(_ action: StackActionOf<Path>, state: inout State) -> Effect<Action> {
        switch action {
        case .element(id: _, action: .agreeToTerms(.delegate(let delegate))):
            return .send(.scope(.agreeToTerms(delegate)))
        case .element(id: _, action: .registerNickname(.delegate(let delegate))):
            return .send(.scope(.registerNickname(delegate)))
        case .element(id: _, action: .selecteField(.delegate(let delegate))):
            return .send(.scope(.selectField(delegate)))
        case .element(id: _, action: .signUpDone(.delegate(let delegate))):
            return .send(.scope(.signUpDone(delegate)))
        case .element, .popFrom, .push:
            return .none
        }
    }
}

//MARK: - Path
extension LoginRootFeature {
    @Reducer
    public enum Path {
        case agreeToTerms(AgreeToTermsFeature)
        case registerNickname(RegisterNicknameFeature)
        case selecteField(SelectFieldFeature)
        case signUpDone(SignUpDoneFeature)
    }
}
