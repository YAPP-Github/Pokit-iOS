//
//  AgreeToTermsFeature.swift
//  Feature
//
//  Created by 김도형 on 7/5/24.

import ComposableArchitecture
import Util

@Reducer
public struct AgreeToTermsFeature {
    /// - Dependency
    @Dependency(\.dismiss) var dismiss
    /// - State
    @ObservableState
    public struct State: Equatable {
        public init() {}
        
        var isAgreeAllTerms: Bool = false
        var isPersonalAndUsageArgee: Bool = false
        var isServiceAgree: Bool = false
        var isMarketingAgree: Bool = false
    }
    /// - Action
    public enum Action: FeatureAction, BindableAction, ViewAction {
        case view(View)
        case inner(InnerAction)
        case async(AsyncAction)
        case scope(ScopeAction)
        case delegate(DelegateAction)
        case binding(BindingAction<State>)
        
        @CasePathable
        public enum View: Equatable {
            case nextButtonTapped
            case backButtonTapped
        }
        public enum InnerAction: Equatable {
            case checkAgreements
            case personalAndUsageAgreeSelected
            case serviceAgreeSelected
            case marketingAgreeSelected
            case allAgreementSelected
        }
        public enum AsyncAction: Equatable { case doNothing }
        public enum ScopeAction: Equatable { case doNothing }
        public enum DelegateAction: Equatable {
            case pushRegisterNicknameView
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
        case .binding(let bindingAction):
            return handleBindingAction(bindingAction, state: &state)
        }
    }
    /// - Reducer body
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce(self.core)
    }
}
//MARK: - FeatureAction Effect
private extension AgreeToTermsFeature {
    /// - View Effect
    func handleViewAction(_ action: Action.ViewAction, state: inout State) -> Effect<Action> {
        switch action {
        case .nextButtonTapped:
            return .send(.delegate(.pushRegisterNicknameView))
        case .backButtonTapped:
            return .run { _ in await self.dismiss() }
        }
    }
    /// - Inner Effect
    func handleInnerAction(_ action: Action.InnerAction, state: inout State) -> Effect<Action> {
        switch action {
        case .checkAgreements:
            let isAgreeAllterm = state.isPersonalAndUsageArgee
            && state.isServiceAgree
            && state.isMarketingAgree
            state.isAgreeAllTerms = isAgreeAllterm
            return .none
        case .personalAndUsageAgreeSelected,
                .serviceAgreeSelected,
                .marketingAgreeSelected:
            return .send(.inner(.checkAgreements))
        case .allAgreementSelected:
            state.isPersonalAndUsageArgee = state.isAgreeAllTerms
            state.isServiceAgree          = state.isAgreeAllTerms
            state.isMarketingAgree        = state.isAgreeAllTerms
            return .none
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
    
    func handleBindingAction(_ action: BindingAction<State>, state: inout State) -> Effect<Action> {
        switch action {
        case \.isAgreeAllTerms:
            return .send(.inner(.allAgreementSelected))
        case \.isPersonalAndUsageArgee:
            return .send(.inner(.personalAndUsageAgreeSelected))
        case \.isServiceAgree:
            return .send(.inner(.serviceAgreeSelected))
        case \.isMarketingAgree:
            return .send(.inner(.marketingAgreeSelected))
        default:
            return .none
        }
    }
}
