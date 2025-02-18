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
    @Dependency(\.dismiss) 
    var dismiss
    @Dependency(\.openURL)
    var openURL
    @Dependency(\.openSettings)
    var openSetting
    @Dependency(PasteboardClient.self)
    var pasteboard
    @Dependency(KeychainClient.self)
    var keychain
    @Dependency(UserDefaultsClient.self) 
    var userDefaults
    @Dependency(AuthClient.self)
    var authClient
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
            case dismiss
            case onAppear
            
            case 프로필설정
            case 알림설정
            case 공지사항
            case 서비스_이용약관
            case 개인정보_처리방침
            case 고객문의
            case 로그아웃_버튼_눌렀을때
            case 로그아웃_팝업_확인_눌렀을때
            case 회원탈퇴_버튼_눌렀을때
            case 회원탈퇴_팝업_확인_눌렀을때
        }
        
        public enum InnerAction: Equatable {
            case 로그아웃_팝업(isPresented: Bool)
            case 회원탈퇴_팝업(isPresented: Bool)
        }
        
        public enum AsyncAction: Equatable {
            case 회원탈퇴_API
            case 키_제거_수행
        }
        
        public enum ScopeAction: Equatable { case 없음 }
        
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
            
        case .dismiss:
            return .run { _ in await dismiss() }
            
        case .프로필설정:
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
            
        case .로그아웃_버튼_눌렀을때:
            return .send(.inner(.로그아웃_팝업(isPresented: true)))
        
        case .로그아웃_팝업_확인_눌렀을때:
            return .run { send in
                await send(.async(.키_제거_수행))
                await send(.inner(.로그아웃_팝업(isPresented: false)))
                await send(.delegate(.로그아웃))
            }
            
        case .회원탈퇴_버튼_눌렀을때:
            return .send(.inner(.회원탈퇴_팝업(isPresented: true)))
        
        case .회원탈퇴_팝업_확인_눌렀을때:
            return .run { send in
                await send(.async(.회원탈퇴_API))
                await send(.inner(.회원탈퇴_팝업(isPresented: false)))
                await send(.delegate(.회원탈퇴))
            }
            
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
        case .회원탈퇴_API:
            return .run { send in
                guard keychain.read(.refreshToken) != nil else {
                    print("refresh가 없어서 벗어남")
                    return
                }
                guard let platform = userDefaults.stringKey(.authPlatform) else {
                    print("platform이 없어서 벗어남")
                    return
                }
                
                if platform == "애플" {
                    guard let authCode = userDefaults.stringKey(.authCode) else {
                        print("authCode가 없어서 벗어남")
                        return
                    }
                    
                    guard let jwt = userDefaults.stringKey(.jwt) else {
                        print("jwt가 없어서 벗어남")
                        return
                    }
                    
                    guard let serverRefreshToken = keychain.read(.serverRefresh) else { return }
                    
                    try await authClient.appleRevoke(
                        serverRefreshToken,
                        AppleTokenRequest(
                            authCode: authCode,
                            jwt: jwt
                        )
                    )
                }
                
                await send(.async(.키_제거_수행))
                
                let request = WithdrawRequest(authPlatform: platform)
                
                try await authClient.회원탈퇴(request)
            }
            
        case .키_제거_수행:
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
