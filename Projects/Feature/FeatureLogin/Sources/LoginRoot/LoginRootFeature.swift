//
//  LoginRootFeature.swift
//  Feature
//
//  Created by 김도형 on 9/7/24.

import ComposableArchitecture
import Util

@Reducer
public struct LoginRootFeature {
    /// - Dependency

    /// - State
    @ObservableState
    public enum State {
        case login(LoginFeature.State)
        case signUpDone(SignUpDoneFeature.State)
    }
    
    /// - Action
    public enum Action {
        case login(LoginFeature.Action)
        case signUpDone(SignUpDoneFeature.Action)
        case delegate(DelegateAction)
    }
    
    public enum DelegateAction {
        case 로그인_루트_닫기
    }
    
    /// - Initiallizer
    public init() {}

    /// - Reducer Core
    private func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .login(.delegate(.회원가입_완료_화면_이동)):
            state = .signUpDone(.init())
            return .none
        case .login(.delegate(.dismissLoginRootView)),
             .signUpDone(.delegate(.dismissLoginRootView)):
            return .send(.delegate(.로그인_루트_닫기))
        case .login, .signUpDone, .delegate:
            return .none
        }
    }
    
    /// - Reducer body
    public var body: some ReducerOf<Self> {
        Reduce(self.core)
            .ifCaseLet(\.login, action: \.login) {
                LoginFeature()
            }
            .ifCaseLet(\.signUpDone, action: \.signUpDone) {
                SignUpDoneFeature()
            }
    }
}
