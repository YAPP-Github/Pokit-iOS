//
//  MainTabFeature.swift
//  App
//
//  Created by 김민호 on 7/11/24.

import ComposableArchitecture
import FeaturePokit
import FeatureRemind
import FeatureLinkDetail
import Util
import CoreKit

@Reducer
public struct MainTabFeature {
    /// - Dependency
    @Dependency(\.pasteboard) var pasteBoard
    /// - State
    @ObservableState
    public struct State: Equatable {
        var selectedTab: MainTab = .pokit
        var isBottomSheetPresented: Bool = false
        var isLinkSheetPresented: Bool = false
        var link: String?
        
        var path: StackState<MainTabPath.State> = .init()
        var pokit: PokitRootFeature.State
        var remind: RemindFeature.State = .init()
        @Presents var linkDetail: LinkDetailFeature.State?
        
        public init() {
            self.pokit = .init(mock: PokitRootCardMock.mock, unclassifiedMock: LinkMock.recommendedMock)
        }
    }
    /// - Action
    public enum Action: FeatureAction, BindableAction, ViewAction {
        case binding(BindingAction<State>)
        case view(View)
        case inner(InnerAction)
        case async(AsyncAction)
        case scope(ScopeAction)
        case delegate(DelegateAction)
        /// Todo: scope로 이동
        case path(StackAction<MainTabPath.State, MainTabPath.Action>)
        case pokit(PokitRootFeature.Action)
        case remind(RemindFeature.Action)
        case linkDetail(PresentationAction<LinkDetailFeature.Action>)

        @CasePathable
        public enum View: Equatable {
            case addButtonTapped
            case addSheetTypeSelected(TabAddSheetType)
            case linkCopyButtonTapped
            case onAppear
        }
        public enum InnerAction: Equatable {
            case 링크추가및수정이동
            case linkCopySuccess(URL?)
        }
        public enum AsyncAction: Equatable { case doNothing }
        public enum ScopeAction: Equatable { case doNothing }
        public enum DelegateAction: Equatable {
            case 링크추가하기
            case 포킷추가하기
        }
    }
    /// initiallizer
    public init() {}
    /// - Reducer Core
    private func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .binding:
            return .none
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
            
        case .path:
            return .none
        case .pokit:
            return .none
        case .remind:
            return .none
        case .linkDetail:
            return .none
        }
    }
    /// - Reducer body
    public var body: some ReducerOf<Self> {
        Scope(state: \.pokit, action: \.pokit) { PokitRootFeature() }
        Scope(state: \.remind, action: \.remind) { RemindFeature() }
        
        BindingReducer()
        navigationReducer
        Reduce(self.core)
            .ifLet(\.$linkDetail, action: \.linkDetail) {
                LinkDetailFeature()
            }
    }
}
//MARK: - FeatureAction Effect
private extension MainTabFeature {
    /// - View Effect
    func handleViewAction(_ action: Action.View, state: inout State) -> Effect<Action> {
        switch action {
        case .addButtonTapped:
            state.isBottomSheetPresented.toggle()
            return .none
            
        case .addSheetTypeSelected(let type):
            state.isBottomSheetPresented = false
            switch type {
            case .링크추가: return .send(.delegate(.링크추가하기))
            case .포킷추가: return .send(.delegate(.포킷추가하기))   
            }
            
        case .linkCopyButtonTapped:
            state.isLinkSheetPresented = false
            return .run { send in await send(.delegate(.링크추가하기)) }

        case .onAppear:
            return .run { send in
                for await _ in self.pasteBoard.changes() {
                    let url = try await pasteBoard.probableWebURL()
                    await send(.inner(.linkCopySuccess(url)))
                }
            }
        }
    }
    /// - Inner Effect
    func handleInnerAction(_ action: Action.InnerAction, state: inout State) -> Effect<Action> {
        switch action {
        case let .linkCopySuccess(url):
            guard let url else { return .none }
            state.isLinkSheetPresented = true
            state.link = url.absoluteString
            return .none
            
        default: return .none
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
