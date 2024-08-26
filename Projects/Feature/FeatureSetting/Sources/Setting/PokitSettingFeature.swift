//
//  PokitSettingFeature.swift
//  Feature
//
//  Created by 김민호 on 7/21/24.

import Foundation

import ComposableArchitecture
import CoreKit
import Util

@Reducer
public struct PokitSettingFeature {
    /// - Dependency
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.openSettings) var openSetting
    @Dependency(\.pasteboard) var pasteboard
    @Dependency(\.keychain) var keychain
    @Dependency(\.userDefaults) var userDefaults
    @Dependency(\.authClient) var authClient
    @Dependency(\.openURL) var openURL
    /// - State
    @ObservableState
    public struct State: Equatable {
        @Presents var nickNameSettingState: NickNameSettingFeature.State?
        var isLogoutPresented: Bool = false
        var isWithdrawPresented: Bool = false
        var isWebViewPresented: Bool = false
        var webViewURL: URL? = nil
        public init() {}
    }
    
    /// - Action
    public enum Action: FeatureAction, ViewAction {
        case view(View)
        case inner(InnerAction)
        case async(AsyncAction)
        case scope(ScopeAction)
        case delegate(DelegateAction)
        case nickNameSettingAction(PresentationAction<NickNameSettingFeature.Action>)
        
        @CasePathable
        public enum View: BindableAction, Equatable {
            case binding(BindingAction<State>)
            case 닉네임설정
            case 알림설정
            case 공지사항
            case 서비스_이용약관
            case 개인정보_처리방침
            case 고객문의
            case 로그아웃
            case 로그아웃수행
            case 회원탈퇴
            case 회원탈퇴수행
            case dismiss
            case onAppear
        }
        
        public enum InnerAction: Equatable {
            case 로그아웃_팝업(isPresented: Bool)
            case 회원탈퇴_팝업(isPresented: Bool)
        }
        
        public enum AsyncAction: Equatable {
            case 회원탈퇴_네트워크
            case 키_제거
        }
        
        public enum ScopeAction: Equatable {
            case doNothing
        }
        
        public enum DelegateAction: Equatable {
            case linkCopyDetected(URL?)
            case 로그아웃
            case 회원탈퇴
        }
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
            
        case .nickNameSettingAction:
            return .none
        }
    }
    
    /// - Reducer body
    public var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)
        Reduce(self.core)
            .ifLet(\.$nickNameSettingState, action: \.nickNameSettingAction) {
                NickNameSettingFeature()
            }
    }
}
//MARK: - FeatureAction Effect
private extension PokitSettingFeature {
    /// - View Effect
    func handleViewAction(_ action: Action.View, state: inout State) -> Effect<Action> {
        switch action {
        case .binding:
            return .none
            
        case .닉네임설정:
            state.nickNameSettingState = NickNameSettingFeature.State()
            return .none
            
        case .알림설정:
            return .run { _ in await openSetting() }
            
        case .공지사항:
            state.webViewURL = Constants.공지사항_주소
            state.isWebViewPresented = true
            return .none
            
        case .서비스_이용약관:
            state.webViewURL = Constants.서비스_이용약관_주소
            state.isWebViewPresented = true
            return .none
            
        case .개인정보_처리방침:
            state.webViewURL = Constants.개인정보_처리방침_주소
            state.isWebViewPresented = true
            return .none
            
        case .고객문의:
            state.webViewURL = Constants.고객문의_주소
            state.isWebViewPresented = true
            return .none
            
        case .로그아웃:
            return .send(.inner(.로그아웃_팝업(isPresented: true)))
        
        case .로그아웃수행:
            return .run { send in
                await send(.async(.키_제거))
                await send(.inner(.로그아웃_팝업(isPresented: false)))
                await send(.delegate(.로그아웃))
            }
            
        case .회원탈퇴:
            return .send(.inner(.회원탈퇴_팝업(isPresented: true)))
        
        case .회원탈퇴수행:
            return .run { send in
                await send(.async(.회원탈퇴_네트워크))
                await send(.inner(.회원탈퇴_팝업(isPresented: false)))
                await send(.delegate(.회원탈퇴))
            }
            
        case .dismiss:
            return .run { _ in await dismiss() }
            
        case .onAppear:
            return .run { send in
                for await _ in self.pasteboard.changes() {
                    let url = try await pasteboard.probableWebURL()
                    await send(.delegate(.linkCopyDetected(url)), animation: .pokitSpring)
                }
            }
        }
    }
    
    /// - Inner Effect
    func handleInnerAction(_ action: Action.InnerAction, state: inout State) -> Effect<Action> {
        switch action {
        case let .로그아웃_팝업(isPresented):
            state.isLogoutPresented = isPresented
            return .none
            
        case let .회원탈퇴_팝업(isPresented):
            state.isWithdrawPresented = isPresented
            return .none
        }
    }
    
    /// - Async Effect
    func handleAsyncAction(_ action: Action.AsyncAction, state: inout State) -> Effect<Action> {
        switch action {
        case .회원탈퇴_네트워크:
            return .run { send in
                guard let refreshToken = keychain.read(.refreshToken) else {
                    print("refresh가 없어서 벗어남")
                    return
                }
                guard let platform = userDefaults.stringKey(.authPlatform) else {
                    print("platform이 없어서 벗어남")
                    return
                }
                
                guard let serverRefreshToken = keychain.read(.serverRefresh) else { return }
                
                let request = WithdrawRequest(refreshToken: serverRefreshToken, authPlatform: platform)
                await send(.async(.키_제거))
                try await authClient.회원탈퇴(request)
            }
            
        case .키_제거:
            keychain.delete(.accessToken)
            keychain.delete(.refreshToken)
            keychain.delete(.serverRefresh)
            return .run { _ in
                await userDefaults.removeString(.authCode)
                await userDefaults.removeString(.jwt)
                await userDefaults.removeString(.authPlatform)
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
