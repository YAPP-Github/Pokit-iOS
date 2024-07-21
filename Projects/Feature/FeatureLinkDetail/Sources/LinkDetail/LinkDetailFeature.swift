//
//  LinkDetailFeature.swift
//  Feature
//
//  Created by 김도형 on 7/19/24.

import UIKit

import ComposableArchitecture
import CoreLinkPresentation
import Util

@Reducer
public struct LinkDetailFeature {
    /// - Dependency
    @Dependency(\.linkPresentation)
    private var linkPresentation
    @Dependency(\.dismiss)
    private var dismiss
    /// - State
    @ObservableState
    public struct State: Equatable {
        public init(link: LinkDetailMock) {
            self.link = link
        }
        
        let link: LinkDetailMock
        var linkTitle: String? = nil
        var linkImage: UIImage? = nil
        var showAlert: Bool = false
    }
    
    /// - Action
    public enum Action: FeatureAction, ViewAction {
        case view(View)
        case inner(InnerAction)
        case async(AsyncAction)
        case scope(ScopeAction)
        case delegate(DelegateAction)
        
        @CasePathable
        public enum View: Equatable, BindableAction {
            case linkDetailViewOnAppeared
            case sharedButtonTapped
            case editButtonTapped
            case deleteButtonTapped
            case deleteAlertConfirmTapped
            case binding(BindingAction<State>)
        }
        
        public enum InnerAction: Equatable {
            case fetchMetadata(url: URL)
            case parsingInfo(title: String?, image: UIImage?)
            case parsingURL
            case dismissAlert
        }
        
        public enum AsyncAction: Equatable { case doNothing }
        
        public enum ScopeAction: Equatable { case doNothing }
        
        public enum DelegateAction: Equatable {
            case pushLinkAddView(link: LinkDetailMock)
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
        }
    }
    
    /// - Reducer body
    public var body: some ReducerOf<Self> {
        Reduce(self.core)
    }
}
//MARK: - FeatureAction Effect
private extension LinkDetailFeature {
    /// - View Effect
    func handleViewAction(_ action: Action.View, state: inout State) -> Effect<Action> {
        switch action {
        case .linkDetailViewOnAppeared:
            return .send(.inner(.parsingURL))
        case .sharedButtonTapped:
            return .none
        case .editButtonTapped:
            return .run { [link = state.link] send in
                await dismiss()
                await send(.delegate(.pushLinkAddView(link: link)))
            }
        case .deleteButtonTapped:
            state.showAlert = true
            return .none
        case .deleteAlertConfirmTapped:
            return .run { send in
                //TODO: 링크 삭제
                await send(.inner(.dismissAlert))
                await dismiss()
            }
        case .binding:
            return .none
        }
    }
    
    /// - Inner Effect
    func handleInnerAction(_ action: Action.InnerAction, state: inout State) -> Effect<Action> {
        switch action {
        case .fetchMetadata(url: let url):
            return .run { send in
                let (title, item) = await linkPresentation.provideMetadata(url)
                let image = linkPresentation.convertImage(item)
                await send(
                    .inner(.parsingInfo(title: title, image: image)),
                    animation: .smooth
                )
            }
        case .parsingInfo(title: let title, image: let image):
            state.linkTitle = title
            state.linkImage = image
            return .none
        case .parsingURL:
            guard let url = URL(string: state.link.url) else {
                state.linkTitle = nil
                state.linkImage = nil
                return .none
            }
            return .send(.inner(.fetchMetadata(url: url)), animation: .smooth)
        case .dismissAlert:
            state.showAlert = false
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
}
