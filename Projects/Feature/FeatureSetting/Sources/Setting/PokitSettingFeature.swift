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
    /// - State
    @ObservableState
    public struct State: Equatable {
        @Presents var nickNameSettingState: NickNameSettingFeature.State?
        var isLogoutPresented: Bool = false
        var isWithdrawPresented: Bool = false
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
        
        public enum InnerAction: Equatable { case doNothing }
        
        public enum AsyncAction: Equatable { case doNothing }
        
        public enum ScopeAction: Equatable {
            case doNothing
        }
        
        public enum DelegateAction: Equatable {
            case linkCopyDetected(URL?)
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
            return .none
            
        case .서비스_이용약관:
            return .none
            
        case .개인정보_처리방침:
            return .none
            
        case .고객문의:
            return .none
            
        case .로그아웃:
            state.isLogoutPresented.toggle()
            return .none
        
        case .로그아웃수행:
            return .none
            
        case .회원탈퇴:
            state.isWithdrawPresented.toggle()
            return .none
        
        case .회원탈퇴수행:
            return .none
            
        case .dismiss:
            return .run { _ in await dismiss() }
            
        case .onAppear:
            return .run { send in
                for await _ in self.pasteboard.changes() {
                    let url = try await pasteboard.probableWebURL()
                    await send(.delegate(.linkCopyDetected(url)))
                }
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
