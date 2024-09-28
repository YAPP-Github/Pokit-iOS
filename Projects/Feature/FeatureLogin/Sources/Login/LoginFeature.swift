//
//  SignUpNavigationStackFeature.swift
//  Feature
//
//  Created by 김도형 on 7/7/24.

import ComposableArchitecture
import CoreKit
import Util

@Reducer
public struct LoginFeature {
    /// - Dependency
    @Dependency(\.dismiss) 
    var dismiss
    @Dependency(SocialLoginClient.self) 
    var socialLogin
    @Dependency(AuthClient.self)
    var authClient
    @Dependency(UserClient.self) 
    var userClient
    @Dependency(UserDefaultsClient.self) 
    var userDefaults
    @Dependency(KeychainClient.self)
    var keychain
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
            case 애플로그인_버튼_눌렀을때
            case 구글로그인_버튼_눌렀을때
        }
        public enum InnerAction: Equatable {
            case 약관동의_화면이동
            case 닉네임_등록_화면이동
            case 관심분야_선택_화면이동(nickname: String)
            case 회원가입_완료_화면이동
            case 로그인_수행(SocialLoginInfo)
            case 로그인_이후_화면이동(isRegistered: Bool)
        }
        public enum AsyncAction: Equatable {
            case 회원가입_API
            case 애플로그인_API(SocialLoginInfo)
            case 구글로그인_API(SocialLoginInfo)
        }
        public enum ScopeAction {
            case agreeToTerms(AgreeToTermsFeature.Action.DelegateAction)
            case registerNickname(RegisterNicknameFeature.Action.DelegateAction)
            case selectField(SelectFieldFeature.Action.DelegateAction)
        }
        public enum DelegateAction: Equatable {
            case dismissLoginRootView
            case 회원가입_완료_화면_이동
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
private extension LoginFeature {
    /// - View Effect
    func handleViewAction(_ action: Action.View, state: inout State) -> Effect<Action> {
        switch action {
        case .애플로그인_버튼_눌렀을때:
            return .run { send in
                let response = try await socialLogin.appleLogin()
                await send(.inner(.로그인_수행(response)))
            }
            
        case .구글로그인_버튼_눌렀을때:
            return .run { send in
                let response = try await socialLogin.googleLogin()
                await send(.inner(.로그인_수행(response)))
            }
        }
    }
    /// - Inner Effect
    func handleInnerAction(_ action: Action.InnerAction, state: inout State) -> Effect<Action> {
        switch action {
        case .약관동의_화면이동:
            state.path.append(.agreeToTerms(AgreeToTermsFeature.State()))
            return .none
        case .닉네임_등록_화면이동:
            state.path.append(.registerNickname(RegisterNicknameFeature.State()))
            return .none
        case .관심분야_선택_화면이동(let nickname):
            state.path.append(.selecteField(SelectFieldFeature.State(nickname: nickname)))
            return .none
        case .회원가입_완료_화면이동:
            return .send(.delegate(.회원가입_완료_화면_이동))
        case let .애플로그인(response):
            return .run { send in
                guard let idToken = response.idToken else { return }
                guard let authCode = response.authCode else { return }
                guard let jwt = response.jwt else { return }
                
                let platform = response.provider.description
                let request = SignInRequest(authPlatform: platform, idToken: idToken)
                let tokenResponse = try await authClient.로그인(request)
                
                /// [1]. UserDefaults에 최근 로그인한 애플로그인 `정보`저장
                await userDefaults.setString(platform, .authPlatform)
                await userDefaults.setString(authCode, .authCode)
                await userDefaults.setString(jwt, .jwt)
                /// [2]. Keychain에 `access`, `refresh` 저장
                keychain.save(.accessToken, tokenResponse.accessToken)
                keychain.save(.refreshToken, tokenResponse.refreshToken)
                
                let appleTokenRequest = AppleTokenRequest(authCode: authCode, jwt: jwt)
                let appleTokenResponse = try await authClient.apple(appleTokenRequest)
                keychain.save(.serverRefresh, appleTokenResponse.refresh_token)
                
                await send(.inner(.로그인_이후_화면이동(isRegistered: tokenResponse.isRegistered)))
            }
        case let .구글로그인_API(response):
            return .run { send in
                guard let idToken = response.idToken else { return }
                let platform = response.provider.description
                let request = SignInRequest(authPlatform: platform, idToken: idToken)
                let tokenResponse = try await authClient.로그인(request)
                
                /// [1]. UserDefaults에 최근 로그인한 소셜로그인 `타입`저장
                await userDefaults.setString(platform, .authPlatform)
                /// [2]. Keychain에 `access`, `refresh` 저장
                keychain.save(.accessToken, tokenResponse.accessToken)
                keychain.save(.refreshToken, tokenResponse.refreshToken)
                keychain.save(.serverRefresh, response.serverRefreshToken)
                
                await send(.inner(.로그인_이후_화면이동(isRegistered: tokenResponse.isRegistered)))
            }
        case let .로그인_이후_화면이동(isRegistered):
            /// [3]. 이미 회원가입했던 유저라면 `메인`이동
            if isRegistered {
                return .run { send in await send(.delegate(.dismissLoginRootView)) }
            } else {
                return .run { send in await send(.inner(.pushAgreeToTermsView)) }
            }
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
                let _ = try await userClient.회원등록(signUpRequest)
                
                await send(.inner(.pushSignUpDoneView))
            }
        
        case .로그인(let response):
            switch response.provider {
            case .apple:
                return .run { send in await send(.inner(.애플로그인(response))) }
            case .google:
                return .run { send in await send(.inner(.구글로그인(response))) }
            }
        }
    }
    /// - Scope Effect
    func handleScopeAction(_ action: Action.ScopeAction, state: inout State) -> Effect<Action> {
        switch action {
        case .agreeToTerms(let delegate):
            switch delegate {
            case .pushRegisterNicknameView:
                return .send(.inner(.닉네임_등록_화면이동))
            }
        case .registerNickname(let delegate):
            switch delegate {
            case .pushSelectFieldView(let nickname):
                state.nickName = nickname
                return .send(.inner(.관심분야_선택_화면이동(nickname: nickname)))
            }
        case .selectField(let delegate):
            switch delegate {
            case let .pushSignUpDoneView(interests):
                state.interests = interests
                return .send(.async(.회원가입_API))
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
        case .element, .popFrom, .push:
            return .none
        }
    }
}

//MARK: - Path
extension LoginFeature {
    @Reducer
    public enum Path {
        case agreeToTerms(AgreeToTermsFeature)
        case registerNickname(RegisterNicknameFeature)
        case selecteField(SelectFieldFeature)
    }
}
