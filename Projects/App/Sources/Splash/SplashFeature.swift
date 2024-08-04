//
//  SplashFeature.swift
//  App
//
//  Created by 김민호 on 7/11/24.

import ComposableArchitecture
import CoreKit
import Util

@Reducer
public struct SplashFeature {
    /// - Dependency
    @Dependency(\.continuousClock) var clock
    @Dependency(\.userDefaults) var userDefaults
    @Dependency(\.authClient) var authClient
    @Dependency(\.keychain) var keychain
    /// - State
    @ObservableState
    public struct State: Equatable {
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
        public enum View: Equatable {
            case onAppear
        }
        public enum InnerAction: Equatable { case doNothing }
        public enum AsyncAction: Equatable { case doNothing }
        public enum ScopeAction: Equatable { case doNothing }
        public enum DelegateAction: Equatable {
            case loginNeeded
            case autoLoginSuccess
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
private extension SplashFeature {
    /// - View Effect
    func handleViewAction(_ action: Action.View, state: inout State) -> Effect<Action> {
        switch action {
        case .onAppear:
            return .run { send in
                try await self.clock.sleep(for: .milliseconds(2000))
                
                /// 🚨 Error Case [1]: 로그인 했던 플랫폼 정보가 없을 때
                guard let _ = userDefaults.stringKey(.authPlatform) else {
                    await send(.delegate(.loginNeeded))
                    return
                }
                /// 🚨 Error Case [2]: refresh Token이 없을 때
                guard let refreshToken = keychain.read(.refreshToken) else {
                    keychain.delete(.accessToken)
                    keychain.delete(.refreshToken)
                    await send(.delegate(.loginNeeded))
                    return
                }
                ///Todo: 토큰 재발급 API 나오면 주석 풀기
//                let tokenRequest = ReissueRequest(refreshToken: refreshToken)
//                let tokenResponse = try await authClient.토큰재발급(tokenRequest)
//                keychain.save(.accessToken, tokenResponse.accessToken)
//                keychain.save(.refreshToken, tokenResponse.refreshToken)
                await send(.delegate(.autoLoginSuccess))
            }
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
        return .none
    }
    /// - Delegate Effect
    func handleDelegateAction(_ action: Action.DelegateAction, state: inout State) -> Effect<Action> {
        return .none
    }
}
