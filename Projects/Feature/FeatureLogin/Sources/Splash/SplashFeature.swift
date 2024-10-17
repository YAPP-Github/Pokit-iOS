//
//  SplashFeature.swift
//  App
//
//  Created by 김민호 on 7/11/24.

import Foundation

import ComposableArchitecture
import CoreKit
import Util

@Reducer
public struct SplashFeature {
    /// - Dependency
    @Dependency(\.continuousClock) 
    var clock
    @Dependency(UserDefaultsClient.self) 
    var userDefaults
    @Dependency(AuthClient.self) 
    var authClient
    @Dependency(KeychainClient.self)
    var keychain
    /// - State
    @ObservableState
    public struct State: Equatable {
        @Shared(.appStorage("isNeedSessionDeleted")) var isNeedSessionDeleted: Bool = true
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
        public enum InnerAction: Equatable {
            case 키_제거
        }
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
            return .run { [isNeedSessionDeleted  = state.isNeedSessionDeleted] send in
                try await self.clock.sleep(for: .milliseconds(2000))
                if isNeedSessionDeleted {
                    guard let platform = userDefaults.stringKey(.authPlatform) else {
                        print("platform이 없어서 벗어남")
                        await send(.inner(.키_제거))
                        await send(.delegate(.loginNeeded))
                        return
                    }
                    // 🚨 이거 구글유저도 분기문 잘 넘어가나 체크해줘!
                    if platform == "애플" {
                        guard let authCode = userDefaults.stringKey(.authCode) else {
                            print("authCode가 없어서 벗어남")
                            await send(.inner(.키_제거))
                            await send(.delegate(.loginNeeded))
                            return
                        }
                        
                        guard let jwt = userDefaults.stringKey(.jwt) else {
                            print("jwt가 없어서 벗어남")
                            await send(.inner(.키_제거))
                            await send(.delegate(.loginNeeded))
                            return
                        }
                        
                        guard let serverRefreshToken = keychain.read(.serverRefresh) else {
                            await send(.inner(.키_제거))
                            await send(.delegate(.loginNeeded))
                            return
                        }
                        
                        try await authClient.appleRevoke(
                            serverRefreshToken,
                            AppleTokenRequest(
                                authCode: authCode,
                                jwt: jwt
                            )
                        )
                        await send(.inner(.키_제거))
                        await send(.delegate(.loginNeeded))
                    }
                }
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

                do {
                    let tokenRequest = ReissueRequest(refreshToken: refreshToken)
                    let tokenResponse = try await authClient.토큰재발급(tokenRequest)
                    keychain.save(.accessToken, tokenResponse.accessToken)
                    await send(.delegate(.autoLoginSuccess))
                } catch {
                    await send(.delegate(.loginNeeded))
                }
//                await send(.delegate(.loginNeeded))
            }
        }
    }
    /// - Inner Effect
    func handleInnerAction(_ action: Action.InnerAction, state: inout State) -> Effect<Action> {
        switch action {
        case .키_제거:
            keychain.delete(.accessToken)
            keychain.delete(.refreshToken)
            keychain.delete(.serverRefresh)
            return .run { [isNeedSessionDeleted = state.$isNeedSessionDeleted] send in
                await userDefaults.removeString(.authCode)
                await userDefaults.removeString(.jwt)
                await userDefaults.removeString(.authPlatform)
                await isNeedSessionDeleted.withLock { $0 = false }
            }
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
