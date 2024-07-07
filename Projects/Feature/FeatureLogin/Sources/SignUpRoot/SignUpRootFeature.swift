//
//  SignUpNavigationStackFeature.swift
//  Feature
//
//  Created by 김도형 on 7/7/24.

import ComposableArchitecture
import CoreKit

@Reducer
public struct SignUpRootFeature {
    /// - Dependency

    /// - State
    @ObservableState
    public struct State {
        var login: LoginFeature.State = .init()
        var agreeToTerms: AgreeToTermsFeature.State = .init()
        var registerNickname: RegisterNicknameFeature.State = .init()
        var path = StackState<Path.State>()
        
        public init() {}
    }
    /// - Action
    public enum Action: FeatureAction {
        case view(ViewAction)
        case inner(InnerAction)
        case async(AsyncAction)
        case scope(ScopeAction)
        case delegate(DelegateAction)
        case path(StackActionOf<Path>)
        case login(LoginFeature.Action)
        
        
        public enum ViewAction: Equatable { case doNothing }
        public enum InnerAction: Equatable {
            case pushAgreeToTermsView
            case pushRegisterNicknameView
            case pushSelectFieldView
            case pushSignUpDoneView
        }
        public enum AsyncAction: Equatable { case doNothing }
        public enum ScopeAction {
            case login(LoginFeature.Action)
            case agreeToTerms(AgreeToTermsFeature.Action.DelegateAction)
            case registerNickname(RegisterNicknameFeature.Action.DelegateAction)
            case selectField(SelectFieldFeature.Action.DelegateAction)
        }
        public enum DelegateAction: Equatable { case doNothing }
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
        case .login(let delegate):
            return .send(.scope(.login(delegate)))
        case .path(.element(id: _, action: .agreeToTerms(.delegate(let delegate)))):
            return .send(.scope(.agreeToTerms(delegate)))
        case .path(.element(id: _, action: .registerNickname(.delegate(let delegate)))):
            return .send(.scope(.registerNickname(delegate)))
        case .path(.element(id: _, action: .selecteField(.delegate(let delegate)))):
            return .send(.scope(.selectField(delegate)))
        default:
            return .none
        }
    }
    /// - Reducer body
    public var body: some ReducerOf<Self> {
        Scope(state: \.login, action: \.login) {
            LoginFeature()
        }
        
        Reduce(self.core)
            .forEach(\.path, action: \.path)
    }
}
//MARK: - FeatureAction Effect
private extension SignUpRootFeature {
    /// - View Effect
    func handleViewAction(_ action: Action.ViewAction, state: inout State) -> Effect<Action> {
        return .none
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
        case .pushSelectFieldView:
            state.path.append(.selecteField(.init()))
            return .none
        case .pushSignUpDoneView:
            state.path.append(.signUpDone(.init()))
            return .none
        }
    }
    /// - Async Effect
    func handleAsyncAction(_ action: Action.AsyncAction, state: inout State) -> Effect<Action> {
        return .none
    }
    /// - Scope Effect
    func handleScopeAction(_ action: Action.ScopeAction, state: inout State) -> Effect<Action> {
        switch action {
        case .login(let delegate):
            switch delegate {
            case .delegate(.pushAgreeToTermsView):
                return .send(.inner(.pushAgreeToTermsView))
            default: return .none
            }
        case .agreeToTerms(let delegate):
            switch delegate {
            case .pushRegisterNicknameView:
                return .send(.inner(.pushRegisterNicknameView))
            }
        case .registerNickname(let delegate):
            switch delegate {
            case .pushSelectFieldView:
                return .send(.inner(.pushSelectFieldView))
            }
        case .selectField(let delegate):
            switch delegate {
            case .pushSignUpDoneView:
                return .send(.inner(.pushSignUpDoneView))
            }
        }
    }
    /// - Delegate Effect
    func handleDelegateAction(_ action: Action.DelegateAction, state: inout State) -> Effect<Action> {
        return .none
    }
}

//MARK: - Path
extension SignUpRootFeature {
    @Reducer
    public enum Path {
        case agreeToTerms(AgreeToTermsFeature)
        case registerNickname(RegisterNicknameFeature)
        case selecteField(SelectFieldFeature)
        case signUpDone(SignUpDoneFeature)
    }
}
